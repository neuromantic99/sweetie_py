from openEphys import openEphys as OE

#channels = list(range(18,48))

singleShankOrder = [36,26,44,24,43,25,35,22,42,23,45,21,41,29,46,20,40,30,47,18,39,19,48,17,38,27,37,28,34,31,33,32]

# remove first 5 channels due to noise
#singleShankOrder = [25,35,22,42,23,45,21,41,29,46,20,40,30,47,18,39,19,48,17,38,27,37,28,34,31,33,32]



fpath = '/Volumes/KohlLab/JamesR/'
fname =  '2017-08-10_20-29-14'

OE.pack_2(fpath + fname, source = '108',filename = fname +  '.dat' , channels = singleShankOrder, dref = 'ave')





