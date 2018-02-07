import readPyControl as pc
import scipy.io as sio
import os
import errno
import numpy as np
import merge as me



'''
Will process all pycontrol txt files given in the directory 'fPath' file.
Structure is not important as the workflow reads the metadata from the header
of the file.

Outputs matlab structures in the directory 'outPath' with folders corresponding 
to a mouse and an individual matlab structure for each behavioural session

'''

fPath = '/media/jamesrowland/DATA/RawData/Behaviour/comb_test'
outPath = '/home/jamesrowland/Documents/ProcessedData/behaviour/2018'


def initialise(fPath, outPath):
   
    checkMerge = getFiles(fPath, ".txt")

    me.check_merge(checkMerge)
    
    txtFiles = getFiles(fPath, ".txt")
    
    for txtFile in txtFiles:
        #this allows you to add 'pass' to a behavioural file's name so it wont be processed
        if 'pass' not in txtFile:      
            try:
                runWorkflow(txtFile, outPath)
                
            except (StopIteration, UnicodeDecodeError):
                print('blank txt files in directory')
                continue
            



def runWorkflow(txtFile, outPath):

    #call Tom's behaviour module       
    my_session = pc.Session(txtFile, False)

    # get the meta data from the header of the txt file
    mData = getMetaData(my_session)
        
    # create the dictionary 'dictOut' which will be saved as a .mat file
    # this requires running the appropriate functions for the type of training
    # and merging the individual dictionaries using the line z = {**x, **y}
    
    if mData['task'] == 'sensory_stimulation':
        dictOut = getSensoryStim(my_session)
        
    # compile relevant dictionaries 
    dictOut = {**mData, **dictOut}

    saveMatStruct(dictOut, outPath)
    
    return dictOut
        
          
def getFiles(fPath, fExt):
    # finds all the files in fPath with subfolders
    # with the extension fExt
   
    fList = []
    # find all the text files in fPath
    for root, dirs, files in os.walk(fPath):
        for file in files:
            if file.endswith(fExt):       
               fList.append(os.path.join(root, file))
        
    return fList
            
    

def getMetaData(my_session):
    
    mData = {}
    #get the ID of the mouse
    ID = my_session.subject_ID
    mData['ID'] = ID.split('_')[0]
    
    # get the date that the session was carried out and use in file name
    mData['date'] = my_session.datetime_string.split()[0]
    
    mData['task'] = my_session.task_name
    
    # get area for imaging sessions    
    aIND = ID.find('area')
    
    
    # get the area string
    if aIND != -1:
        area = ID[aIND:]
    else:
        area = ''
        
    mData['area'] = area
        
         
    return mData


def getTTL(my_session):

    try:
        tS = my_session.times.get('TTL_in')[0]        
    except:
        tS = []
        print('could not find a trigger for the imaging session %s ' %my_session.file_name)
        
    try:
        tEnd = my_session.times.get('TTL_out')[0] - tS
    except:
        tEnd = []
        
    return tS, tEnd


def subTTL(dic,tS):

    # function that subtracts the start tS (TTL_in) from times in dictionary 'dic'         
    for key, val in dic.items():
        val = np.array(val)
        # only subtract the TTL from the running time stamp
        
        if key == 'running':
            val[:,0] = val[:,0] - tS
            dic[key] = val
        else:
            dic[key] = val - tS 
    
    return dic


def motor(my_session):
    # the motor starts moving
    
    mInfo = {}
    
    mInfo['motor_start'] = my_session.times.get('motor_forward')
    #the motor arrives at the whiskers
    mInfo['motor_atWhisk'] = my_session.times.get('stim_interval')
    #the motor starts back
    mInfo['motor_back'] = my_session.times.get('motor_backward')

    #the motor arrives back cut off first origin as this is start of session
    if my_session.task_name == 'sensory_stimulation':
        mInfo['motor_atOrigin'] = my_session.times.get('trial_start')
                
    return mInfo

def getRunning(my_session):
    #get the file identifer by removing the .txt
    txt = my_session.file_name
    stamp = txt.split('.txt')[0]
    
    allPCAs = getFiles(my_session.file_path, '.pca')
   
    pca = [f for f in allPCAs if stamp in f]
    
    try:
        running = pc.load_analog_data(pca[0])
    except IndexError:
        raise AssertionError('likely missing PCA files to match txt files' )
    
    # same format as read in txt file
    running = running.astype(np.int64)
    
    return running

    

def getSensoryStim(my_session):
    # return all the values that need TTL subtraction before the rest
    ssInfo = {}
    
    ssInfo['running'] = getRunning(my_session)
    motInf = motor(my_session)
    ssInfo = {**ssInfo, **motInf}
    # subtract the TTL time
    TTL, endTTL = getTTL(my_session)
    ssInfo = subTTL(ssInfo, TTL)
    
    ssInfo['endTTL'] = endTTL
    
    
    # do not need TTL subtraction and have left these as strings to prevent allignment to imaging in matlab
    ssInfo['stim_position'] = [line.split()[5] for line in my_session.print_lines if 'whisker stim position is' in line]
    ssInfo['stim_speed'] = [line.split()[3] for line in my_session.print_lines if 'speed is' in line]
    return ssInfo


def saveMatStruct(dictOut, outPath):
    
   # the path to the mouse specific folder
    savePath = outPath + '/' + dictOut['ID'] + '/'
     
    # create the mouse specific folder if it does not already exist
    if not os.path.exists(os.path.dirname(savePath)):
        try:
            os.makedirs(os.path.dirname(savePath))
        except OSError as exc: # Guard against race condition
            if exc.errno != errno.EEXIST:
                raise


    #save the dictionary as a matlab structure in the mouse folder
    sio.savemat(savePath + dictOut['task'] + '_' + dictOut['date'] + '_' + dictOut['area'] + '.mat',{'behavioural_data':dictOut}) 


# use this to debug
#t = '/media/jamesrowland/DATA/RawData/Behaviour/2018/GTRS1.5d_area01-2018-01-26-154446.txt'
#t = '/media/jamesrowland/DATA/RawData/Behaviour/comb_test/testTTLout-2018-02-01-114116.txt'
#do = runWorkflow(t, outPath)
  
initialise(fPath, outPath)
































