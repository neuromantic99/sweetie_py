from openEphys import openEphys as OE
import numpy as np

filePath = '/Users/James/Desktop/Raw_recordings/2017-07-06_18-27-01/'

events = OE.load(filePath + 'all_channels.events')
cont = OE.load(filePath + '108_CH23.continuous')
sampleRate = 30000

contTimes = cont['timestamps'] / sampleRate

eventType = events['eventType']
tStamps = events['timestamps']
channel = events['channel']


times = tStamps / sampleRate

TTLsInd = np.where(eventType == 3)[0]
nonTTL = np.where(eventType == 5)[0]

TTLs = []
channelsTTL = []
for i in TTLsInd:
    TTL = times[i]
    TTLs.append(TTL)
    
    channelsTTL.append(channel[i])
 
 # there is a missing value in this dataset, add random integer to further processing    
TTLs.append(55)
channelsTTL.append(55)
   
TTLs = np.asarray(TTLs) 
channelsTTL = np.asarray(channelsTTL)

comb = np.vstack((TTLs, channelsTTL))
comb = np.transpose(comb)

recIND = np.where(channelsTTL == 9)[0]

numRecords = len(recIND)

numTTLperRecord = (len(channelsTTL) - (numRecords - 1)) / numRecords
numTTLperRecord = int(numTTLperRecord)

chunked = np.zeros((numTTLperRecord, 2, numRecords))

for i in range(numRecords):
    startRec = recIND[i] + 1
    
    if i == numRecords - 1:
        
        endRec = len(channelsTTL) 
    
    else:
        
        endRec = recIND[i+1]
   
    chunked[:,:,i] = comb[startRec:endRec,:]
    
    
contGaps = []

for i in range(len(contTimes)):
    if i == 0:
        contGaps.append(0)
    else:
        contGaps.append(contTimes[i] - contTimes[i-1])
        
contGaps = np.asarray(contGaps)
recordStarts = np.where(contGaps > 1)[0]

recordStarts = np.insert(recordStarts,0,0)


    
normalised = np.zeros((numTTLperRecord, 2, numRecords))  

for i in range(numRecords):
     if i == 0:
         normaliser = contTimes[0]

     else:
         normaliser = contTimes[recordStarts[i]] - contTimes[recordStarts[i] - 1] 
     print(normaliser)
     if i == 3:
         contTimes[recordStarts[i]:-1] = contTimes[recordStarts[i]:-1] - normaliser
         
     else:
         contTimes[recordStarts[i]:recordStarts[i+1]] = contTimes[recordStarts[i]:recordStarts[i+1]] - normaliser
     for ii in range(numTTLperRecord):
       
        chunked[ii,0,i] = chunked[ii,0,i] - normaliser
        
        
        
        
        
        
       
        







