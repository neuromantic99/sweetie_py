import openEphys as OE
import numpy as np
import scipy.io


filePath = '/home/jamesrowland/Documents/Ephys_Data/2017-08-10_17-33-13/'

# use the openEphys module to load the events datafile and one continous file
# continuous file is used to allignment purposes only

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


TTLs = [times[i] for i in TTLsInd]
channelsTTL = [channel[i] for i in TTLsInd]

 # there is a missing value in this dataset, add random integer for further processing    
TTLs.append(55)
channelsTTL.append(55)
   
# make array to allow to use matrix concat
TTLs = np.asarray(TTLs) 
channelsTTL = np.asarray(channelsTTL)

# probabaly a horrendous way of concatenating arrays
comb = np.vstack((TTLs, channelsTTL))
comb = np.transpose(comb)

# index of where recordings start
recIND = np.where(channelsTTL == 9)[0]


numRecords = len(recIND)


numTTLperRecord = (len(channelsTTL) - (numRecords - 1)) / numRecords
numTTLperRecord = int(numTTLperRecord)

# establish an array containing the time of each TTL and the channel ID
# sorted by their recording number
chunked = np.zeros((numTTLperRecord, 2, numRecords))

for i in range(numRecords):
    startRec = recIND[i] + 1
    
    if i == numRecords - 1:
        
        endRec = len(channelsTTL) 
    
    else:
        
        endRec = recIND[i+1]
   
    chunked[:,:,i] = comb[startRec:endRec,:]
    
#figure out the time that each recording started. This is achieved by
# checking for any consecutive samples that are more than 1 second apart

contGaps = []

for i in range(len(contTimes)):
    if i == 0:
        contGaps.append(0)
    else:
        contGaps.append(contTimes[i] - contTimes[i-1])
        
contGaps = np.asarray(contGaps)
recordStarts = np.where(contGaps > 1)[0]

# insert the recording time of 0
recordStarts = np.insert(recordStarts,0,0)

# normalise the times in the 'chunked' array so they are displayed consecutively 
# the normaliser variable is the gap between the end of one recording and the start 
# of the next one

for i in range(numRecords):
     if i == 0:
         normaliser = contTimes[0]

     else:
         normaliser = contTimes[recordStarts[i]] - contTimes[recordStarts[i] - 1] 
     print(normaliser)
     if i == numRecords -1 :
         contTimes[recordStarts[i]:-1] = contTimes[recordStarts[i]:-1] - normaliser
         
     else:
         contTimes[recordStarts[i]:recordStarts[i+1]] = contTimes[recordStarts[i]:recordStarts[i+1]] - normaliser
     for ii in range(numTTLperRecord):
       
        chunked[ii,0,i] = chunked[ii,0,i] - normaliser


#optoChunkedIND = np.zeros((numTTLperRecord, numRecords));
#
#row = np.where(chunked == 2)
#        
#
#
#
#
#
#     
#for i in range(numRecords):
#     
#         if chunked[0,1,i] == 2.000:
#             chunked[0,1,i] = 200
#         elif chunked[0,1,i] == 5.000:
#             chunked[0,1,i] = 500
#             
# 
#for i in range(numRecords):
#             
#         if chunked[1,1,i] == 2.000:
#             
#             if chunked[0,1,i] == 200:
#                 chunked[1,1,i] = 250
#             else:
#                 chunked[1,1,i] ==200
#                 
#         if chunked[1,1,i] == 5.000:
#             if chunked[0,1,i] == 500:
#                 chunked[1,1,i] = 550
#             else:
#                 chunked[1,1,i] = 500
#
#               
#                 
#             
#             
#
# 
#for i in range(numRecords):
#     for ii in range(2, numTTLperRecord):
#         
#         if chunked[ii,1,i] == 2.000 and chunked[ii-1,1,i] != 200 and chunked[ii-2,1,i] != 200 and chunked[ii-3,1,i] != 200:
#             
#             #if chunked[ii-3,1,i] != 200 or chunked[ii-1,1,i] != 250 or chunked[ii-2,1,i] != 250:
#             chunked[ii,1,i] = 200
#         elif chunked[ii,1,i] == 2.000:
#             chunked[ii,1,i] = 250
#
#              
#         if chunked[ii,1,i] == 5.000 and chunked[ii-1,1,i] != 500 and chunked[ii-2,1,i] != 500:
#             chunked[ii,1,i] = 500
#         elif chunked[ii,1,i] == 5.000:
#             chunked[ii,1,i] = 550
#             
#
#
## Specify the filename of the .mat file
#matfile = '2017-07-20_17-33-13.mat'
#
## Write the array to the mat file. For this to work, the array must be the value
## corresponding to a key name of your choice in a dictionary
#scipy.io.savemat(matfile, mdict={'out': chunked}, oned_as='row')

