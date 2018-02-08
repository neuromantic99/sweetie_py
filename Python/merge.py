import readPyControl as pc
import numpy as np
import os


def check_merge(txtFiles):
    
    toMerge = []
    for txtFile in txtFiles:
        
        if 'IVE_BEEN_MERGED' in txtFile:
            continue
        
        my_session = pc.Session(txtFile, False)
        
        ID = my_session.subject_ID
        area = ID.split('_')[1]
        
        
        if area[-1].isalpha() == 1:
            toMerge.append(txtFile)
               
    mf = mergeList(toMerge)
    
    return mf
 

def mergeList(toMerge):
    
    mCount = 0
    IDlst = []
    datelst = []
    arealst = []
    mergeIND = []
    
    for i,tm in enumerate(toMerge):
     
        my_session = pc.Session(tm, False)
        ID = my_session.subject_ID.split('_')
        IDlst.append(ID[0])
        datelst.append(my_session.datetime_string.split()[0])
        arealst.append(ID[1][0:6])
        
        if i >=1:
            if IDlst[i-1] != IDlst[i] or datelst[i-1] != datelst[i] or arealst[i-1] != arealst[i]:

                mCount = mCount + 1

        mergeIND.append(mCount)
        
    mf = mergeIndex(mergeIND, toMerge)
   
    return mf

def mergeIndex(mergeIND, toMerge):
    
    #unique values
    uni = set(mergeIND)
    for clust in uni:
    
        mergeIND = np.array(mergeIND)
        a = np.where(mergeIND == clust)[0]
        
        mergeGroup = [toMerge[b] for b in a]
        
        doMergePCA(mergeGroup)
        doMerge(mergeGroup)
        
        

    
def doMerge(mergeGroup):
    sessionA = pc.Session(mergeGroup[0], False)
    sessionB = pc.Session(mergeGroup[1], False)
    txtA = sessionA.merge_lines
    txtB = sessionB.merge_lines
    # end of the first behaviour
    tEnd = sessionA.times.get('TTL_out')[0] 
    # start of the second behaviour
    tStart = sessionB.times.get('TTL_in')[0]
    # get the behaviour in the first instance that occured before the TTL out
    lineSplitA = [line.split(' ') for line in txtA]
    save = [' '.join(line) for line in lineSplitA if int(line[1]) < tEnd]
    
    # get the behaviour in the second instance that occured after TTL in
    lineSplitB = [line.split(' ') for line in txtB]
    postTTL = [line for line in lineSplitB if int(line[1]) > tStart]

    
    # add the previous TTL
    added = [int(line[1]) + tEnd for line in postTTL]
    # subtract the second TTL
    subbed = [t - tStart for t in added]

 
    rejoin = []
    for idx in range(len(postTTL)):
        
        postTTL[idx][1] = str(subbed[idx])
        rejoin.append(' '.join(postTTL[idx]))
        
    #merge the two lists
    save.extend(rejoin)
    # text file headers
    header = sessionA.headers
    #ditch the letter from the area
    header[2] = header[2][:-1]

    # add the data to the header
    header.extend(save)

    fPath = sessionA.file_path + '/' + sessionA.subject_ID[:-1] + '_IVE_BEEN_MERGED' + '.txt'

    with open(fPath, 'w') as f:
        f.writelines(i + '\n' for i in header) 

    os.remove(mergeGroup[0])
    os.remove(mergeGroup[1])

def doMergePCA(mergeGroup):
    sessionA = pc.Session(mergeGroup[0], False)
    sessionB = pc.Session(mergeGroup[1], False)
    
    # end of the first behaviour
    tEnd = sessionA.times.get('TTL_out')[0] 
    # start of the second behaviour
    tStart = sessionB.times.get('TTL_in')[0]
    
    for root, dirs, files in os.walk(sessionA.file_path):
        for file in files:
            if file.endswith('.pca') and sessionA.datetime_string.split(' ')[0] in file and sessionA.subject_ID in file:   
                fPathA = os.path.join(root, file)
                runA = pc.load_analog_data(fPathA)
                

    for root, dirs, files in os.walk(sessionB.file_path):
        for file in files:
            if file.endswith('.pca') and sessionB.datetime_string.split(' ')[0] in file and sessionB.subject_ID in file:  
                fPathB = os.path.join(root, file)
                runB = pc.load_analog_data(fPathB)


    # preTTL in second file
    a = np.where(runB[:,0] > tStart)  
    runB = runB[a]
    # add the TTL from the first trial and subtract the TTL from the second
    runB[:,0] = runB[:,0] + tEnd - tStart
    
    # remove post TTL from the first
    b = np.where(runA[:,0] < tEnd)
    runA = runA[b]

    #merge the two
    runM = np.vstack((runA, runB))
    
    fPath = sessionA.file_path + '/' + sessionA.subject_ID[:-1] + '_IVE_BEEN_MERGED' + '.pca'
    
    with open(fPath, 'wb') as f:
         f.writelines([i for i in runM]) 
         
    os.remove(fPathA)
    os.remove(fPathB)



            
        