from openEphys import openEphys as OE
import matplotlib.pyplot as plt
import numpy as np


LFPs = []
for i in range(1,65):
    fpath = '/Volumes/KohlLab/JamesR/PV2_whisker/'
    fname = (fpath + '108_CH%s.continuous'  %i)
    data  = OE.load(fname)
    print(fname)
    fullSignal = data['data']
    downSampled = fullSignal[::50]
    LFPs.append(downSampled)

timeRecord = len(LFPs[1] / 30000 / 60)
    

truncLFPs = []
for LFP in LFPs:
    
    truncLFP = LFP[1000 : 100000]
    truncLFPs.append(truncLFP)



plt.figure()
ax0 = plt.subplot(8,8,1)
plt.plot(truncLFPs[0])
ax0.set_title('channel 1')

ax0.set_ylim([-1000, 2500])
ax0.set_autoscaley_on(False)


for i in range(2,64):
    ax = plt.subplot(8,8,i, sharey = ax0)
    
    datam = truncLFPs[i-1]
    
    ax.plot(datam)
    ax.set_ylim([-1000, 2500])
    ax.set_title('channel %s' %i)
    plt.axis('off')

    
plt.show()


#==============================================================================
# 
# 
# 
# plt.figure()
# ax0 = plt.subplot(8,4,1)
# plt.plot(truncLFPs[0])
# ax0.set_title('channel 1')
# plt.axis('off')
# 
# for i in range(1,32):
#     ax = plt.subplot(8,4,i+1, sharey = ax0)
#     
#     datam = truncLFPs[i]
#     
#     ax.plot(datam)
#     ax.set_title('channel %s' %i)
#     plt.axis('off')
# 
#     
# plt.show()
#==============================================================================

