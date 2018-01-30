import readPyControl as pc
import scipy.io as sio
import os
import errno
import numpy as np


'''
Will process all pycontrol txt files given in the directory 'fPath' file.
Structure is not important as the workflow reads the metadata from the header
of the file.

Outputs matlab structures in the directory 'outPath' with folders corresponding 
to a mouse and an individual matlab structure for each behavioural session

'''

fPath = '/media/jamesrowland/DATA/RawData/Behaviour/2018'
outPath = '/home/jamesrowland/Documents/ProcessedData/behaviour/2018'


def initialise(fPath, outPath):
   
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
        
    # add the metadata to the dictionary
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
    
    
    
    if aIND != -1:
        mData['area'] = ID[aIND:aIND+6]
    else:
        mData['area'] = ''
     
    return mData


def getTTL(my_session):
            
    try:
        tS = my_session.times.get('TTL_in')[0]
    except:
        tS = []
        print('could not find a trigger for the imaging session %s ' %my_session.file_name)
        
    return tS


def subTTL(dic,tS):
    
    # function that subtracts the start tS (TTL_in) from times in dictionary 'dic'         
    for key, val in dic.items():
        dic[key] = np.array(val) - tS 
    
    return dic


def motor(my_session):
    # the motor starts moving
    fStart = my_session.times.get('motor_forward')
    
    #the motor arrives at the whiskers
    atWhiskers = my_session.times.get('stim_interval')

    #the motor starts back
    bStart = my_session.times.get('motor_backward')

    # I haven't added the time that the motor arrives back
    # at the start position because it's the different
    # depending on the task, but can be done
    
    # concatenate, taking into account that the behaviour may end half way
    # through a trial
    mInfo = np.vstack((fStart[0:len(bStart)], atWhiskers[0:len(bStart)], bStart))
        
    return mInfo

def getRunning(my_session):
    #get the file identifer by removing the .txt
    txt = my_session.file_name
    stamp = txt.split('.txt')[0]
    
    allPCAs = getFiles(my_session.file_path, '.pca')
    pca = [f for f in allPCAs if stamp in f]

    running = pc.load_analog_data(pca[0])
    
    return running
    


def getSensoryStim(my_session):
    # return all the values that need TTL subtraction before the rest
    ssInfo = {}
    
    ssInfo['running'] = getRunning(my_session)
    ssInfo['mInfo'] = motor(my_session)
    
    # subtract the TTL time
    TTL = getTTL(my_session)
    ssInfo = subTTL(ssInfo, TTL)
    
    # do not need TTL subtraction have left these as strings to prevent allignment to imaging in matlab
    ssInfo['motor_position'] = [line.split()[5] for line in my_session.print_lines if 'whisker stim position is' in line]
    ssInfo['motor_speed'] = [line.split()[3] for line in my_session.print_lines if 'speed is' in line]
  
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


  
initialise(fPath, outPath)
    




