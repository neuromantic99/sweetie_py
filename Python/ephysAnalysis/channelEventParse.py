import openEphys as OE
import numpy as np

filePath = '/home/jamesrowland/Documents/Ephys_Data/2017-08-10_17-33-13/'

# use the openEphys module to load the events datafile and one continous file
# continuous file is used for allignment purposes only

events = OE.load(filePath + 'all_channels.events')
cont = OE.load(filePath + '108_CH15.continuous')

sampleRate = 30000

# list of all the times that recording was occuring
contTimes = cont['timestamps'] / sampleRate


eventType = events['eventType']
tStamps = events['timestamps']
channel = events['channel']

times = tStamps / sampleRate

# TTL events are stored as event type 3
TTLsInd = np.where(eventType == 3)[0]
nonTTL = np.where(eventType == 5)[0]

# get the times that TTL events occured
TTLs = [times[i] for i in TTLsInd]
channelsTTL = [channel[i] for i in TTLsInd]

# sometimes there is a missing value in the dataset.
# this can be solved by adding a random integer for further processing    
TTLs.append(55)
channelsTTL.append(55)
   
# make array to allow to use matrix concat
TTLs = np.asarray(TTLs) 
channelsTTL = np.asarray(channelsTTL)

# probabaly a really bad way of concatenating arrays
comb = np.vstack((TTLs, channelsTTL))
comb = np.transpose(comb)

# the start of the recording (signifiying a new stimulation protocol
# is reported on channel 9.
# so get the index of where each recording started
recIND = np.where(channelsTTL == 9)[0]


numRecords = len(recIND)

# the number of TTLs recieved in each recording
numTTLperRecord = (len(channelsTTL) - (numRecords - 1)) / numRecords
numTTLperRecord = int(numTTLperRecord)

# establish an array containing the time of each TTL and the channel ID
# sorted by their recording number
sortByRecord = np.zeros((numTTLperRecord, 2, numRecords))

for i in range(numRecords):
    startRec = recIND[i] + 1
    
    if i == numRecords - 1:
        
        endRec = len(channelsTTL) 
    
    else:
        
        endRec = recIND[i+1]
   
    sortByRecord[:,:,i] = comb[startRec:endRec,:]
    
#figure out the time that each recording started. This is achieved by
# checking for any consecutive samples that are more than 1 second apart
    
contGaps = []

for i in range(len(contTimes)):
    if i == 0:
        contGaps.append(0)
    else:
        contGaps.append(contTimes[i] - contTimes[i-1])
        
contGaps = np.asarray(contGaps)

# create the variable 'recordStarts' corresponding to
# when there is a gap of more than 1 second
# this is because it will always take me more than
# 1 second to start the next recording
recordStarts = np.where(contGaps > 1)[0]

# insert the recording time of 0
recordStarts = np.insert(recordStarts,0,0)

# normalise the times in the 'sortByRecord' array so they are displayed consecutively 
# the normaliser variable is the gap between the end of one recording and the start 
# of the next one

for i in range(numRecords):
     if i == 0:
         normaliser = contTimes[0]

     else:
         normaliser = contTimes[recordStarts[i]] - contTimes[recordStarts[i] - 1] 

     if i == numRecords -1 :
         contTimes[recordStarts[i]:-1] = contTimes[recordStarts[i]:-1] - normaliser
         
     else:
         contTimes[recordStarts[i]:recordStarts[i+1]] = contTimes[recordStarts[i]:recordStarts[i+1]] - normaliser
     for ii in range(numTTLperRecord):
       
        sortByRecord[ii,0,i] = sortByRecord[ii,0,i] - normaliser

