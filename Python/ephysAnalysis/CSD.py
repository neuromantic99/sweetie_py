from channelEvents import channelEvents as CE
import numpy as np
from openEphys import openEphys as OE
import matplotlib.pyplot as plt
import seaborn as sns
from scipy.signal import butter, lfilter, freqz


def butter_bandpass(highcut, fs, order=2):
    nyq = 0.5 * fs
   # low = lowcut / nyq
    high = highcut / nyq
    b, a = butter(order, high, btype='low')
    return b, a


def butter_bandpass_filter(data, highcut, fs, order=2):
    b, a = butter_bandpass(highcut, fs, order=order)
    y = lfilter(b, a, data)
    return y


filePath = '/Volumes/KohlLab/JamesR/2017-08-08_17-57-44/'
singleShankOrder = [36,26,44,24,43,25,35,22,42,23,45,21,41,29,46,20,40,30,47,18,39,19,48,17,38,27,37,28,34,31,33,32]

tester = OE.load(filePath + '108_CH1.continuous')['data']


LFPs = np.zeros((32, len(tester)))



for i in range(len(singleShankOrder)):
    channel = singleShankOrder[i]
    
    cont = OE.load(filePath + '108_CH' + str(channel) +  '.continuous')
    LFPs[i,:] = cont['data']
    

    

    
    
    
# divide the length of 1 LFP by the total number of trials
numTrials = 240
chunkSize = int(len(tester)/numTrials)


avdLFPs = np.zeros((32, chunkSize))

for chan in range(len(LFPs)):
    
   # need to change where the division happens depending on recording
    LFP = LFPs[chan, int(len(tester)/4):int(len(tester)/2)]
    #LFP = LFP[0:-1:3]
    chunked =  [LFP[i:i + chunkSize] for i in range(0, len(LFP), chunkSize)]
    chunked = chunked[0:60]
    avdLFPs[chan, :] = np.mean(chunked,0)
    

# duplicate first and final channels for smoothing process
avdLFPs = np.insert(avdLFPs,0, avdLFPs[0,:], axis = 0)
avdLFPs = np.insert(avdLFPs,-1, avdLFPs[-1,:], axis = 0)
filtered = np.zeros((34, chunkSize))

for i in range(len(avdLFPs)):
    unfiltered = avdLFPs[i,:]
    filtered[i,:] = butter_bandpass_filter(unfiltered, 1000, 30000)


smoothed = np.zeros((32, chunkSize))

for i in range(32):
    for ii in range(len(avdLFPs[1,:])):
  
        chanIndex = i + 1
        chan = filtered[chanIndex,ii]
        prevChan = filtered[chanIndex-1,ii]
        nextChan = filtered[chanIndex+1,ii]
     
        smoothed[i,ii] = 0.25 * (nextChan + 2 * chan + prevChan)
        
CSD = np.zeros((32, chunkSize))

smoothed = np.insert(smoothed,0, smoothed[0,:], axis = 0)
smoothed = np.insert(smoothed,-1, smoothed[-1,:], axis = 0)



for i in range(32):
    for ii in range(len(avdLFPs[1,:])):
        chanIndex = i + 1
        chan = smoothed[chanIndex,ii]
        prevChan = smoothed[chanIndex-1,ii]
        nextChan = smoothed[chanIndex+1,ii]
        
        CSD[i,ii] = 1/pow(0.25,2) * (nextChan - 2 * chan + prevChan)
        
        
        
        
        
truncCSD =CSD[0:33, 60000:64000]
 

#==============================================================================
#truncCSD[1,:] = np.zeros(len(truncCSD[1,:]))
#truncCSD[3,:] = np.zeros(len(truncCSD[1,:]))
#truncCSD[5,:] = np.zeros(len(truncCSD[1,:]))
#==============================================================================

  
flipped = np.flipud(truncCSD)      


x = range(len(truncCSD[1,:]))
y = np.linspace(0,33, len(truncCSD))

#-625, -25
plt.close('all')
ax = plt.pcolormesh(x, y, truncCSD, cmap = 'jet')
plt.colorbar() #need a colorbar to show the intensity scale
plt.ylabel('Depth um')
#plt.xticks([])
plt.show() 
        
        

        


#==============================================================================
# 
# f, axarr = plt.subplots(2, sharey = True)
# 
# axarr[0].plot(avdLFPs[12,:])
# axarr[1].plot(smoothed[11,:])
#==============================================================================
