import readPyControl as pc
import numpy as np
import scipy.io as sio
import os
import errno

'''
Will process all pycontrol txt files given in the directory 'fPath' file.
Structure is not important as the workflow reads the metadata from the header
of the file.

Outputs matlab structures in the directory 'outPath' with folders corresponding 
to a mouse and an individual matlab structure for each behavioural session

'''

fPath = '/home/jamesrowland/Documents/RawBehaviour/'
outPath = '/home/jamesrowland/Documents/ProcessedData/behaviour/'



def runWorkflow(txtFile, outPath):

    #call Tom's behaviour module    
    my_session = pc.Session(txtFile, False)

    # get the meta data from the header of the txt file
    [ID, date, sessionType,go_pos] = getMetaData(my_session)
        
    # append the basic information required in all behaviours to the dictionary
    basicInfo = getBasicInfo(my_session)
    
    # create the dictionary 'dictOut' which will be saved as a .mat file
    # this requires running the appropriate functions for the type of training
    # and merging the individual dictionaries using the line z = {**x, **y}

    if sessionType == 'habituation':
        dictOut = basicInfo
    elif sessionType == 'recognition':
        training = getTraining(my_session)
        dictOut = {**basicInfo, **training}
    elif sessionType == 'discrimination':
        training = getTraining(my_session)
        discrim = getDiscrimination(my_session, go_pos)
        dictOut = {**basicInfo, **training, **discrim}

    saveMatStruct(dictOut, outPath, ID, sessionType, date)
        
def getTxtFiles(fPath):
   
    txtFiles = []
    # find all the text files in fPath
    for root, dirs, files in os.walk(fPath):
        for file in files:
            if file.endswith(".txt"):       
               txtFiles.append(os.path.join(root, file))
               
    return txtFiles
        
        

def getMetaData(my_session):
    #get the ID of the mouse 
    ID = my_session.subject_ID
              
    # get the date that the session was carried out and use in file name
    date = my_session.datetime_string.split()[0]
    
    go_pos = 'None'
    
    # find the task the mouse did corresponding to the text file.
    # call the function relevant to that task 
    if 'habituation' in my_session.experiment_name:      
        sessionType = 'habituation' 
        
        
    elif 'training' in my_session.experiment_name:
        if 'position' in my_session.experiment_name:
            sessionType = 'discrimination'      
            go_pos = getGoPos(my_session)
        else:     
            sessionType = 'recognition'
    else:
        raise ValueError('Could not assign task to text file %s' %my_session.experiment_name)

        
        
            
             
    return ID, date, sessionType, go_pos

def getGoPos(my_session):
    
    # find whether go position is forward or backwards by splitting the go position
    # string on the value '1' indicating the go position
    
    foundGo = False
    
    for line in my_session.print_lines:
       if 'correct position is' in line:
           foundGo = True
           split1 = (line.split('1',1)[1])
           if 'is forward' in split1:
               go_pos = 1
           elif 'is backward' in split1:
               go_pos  = 0
           else:
               raise ValueError ('failed to find go position value in file %s' %(my_session.subject_ID))
   
    if foundGo == False:
        print('%s' %my_session.subject_ID)
        print('%s' %my_session.datetime_string)
        raise ValueError ('failed to find go position  in file %s' %my_session.subject_ID)
       
    return go_pos
    
    
   
def searchPrintLines(my_session, I):
    
    '''
    function that searches through the lines for the string 'I'. 
    returns a list of the times (ms) that the string was printed
    during behaviour  
    '''
    
    l = []
    for line in my_session.print_lines:
        if line.split()[1] == I:
            value = line.split()[0]
            l.append(value)
    return l
    
        
    
def getBasicInfo(my_session):
    
    basicInfo = {}
    
    water = searchPrintLines(my_session, 'waterON')
    
    basicInfo['running_forward'] =  my_session.times['going_forward']
    basicInfo['licks'] =  my_session.times['lick_event']    
    basicInfo['water_delivered'] = water
    
    return basicInfo


        

def getTraining(my_session):
        
    training = {}

    correct = searchPrintLines(my_session, 'correct')
    missed = searchPrintLines(my_session, 'missed')
    false =  searchPrintLines(my_session, 'false_positive')
    
    training['correct_trials'] =  correct
    training['missed_trials'] = missed
    training['falsepositive_trials'] = false
    
    return training
    

def getDiscrimination(my_session, go_pos):
    
    discrim = {}
        
    reject = searchPrintLines(my_session,'rejection')
    fp = searchPrintLines(my_session, 'false_positive')
    lick = searchPrintLines(my_session, 'lick')

    if go_pos == 1:
        go =  searchPrintLines(my_session, 'forward_position')
        nogo =  searchPrintLines(my_session, 'backward_position')
    elif go_pos == 0:
        go = searchPrintLines(my_session, 'backward_position')
        nogo = searchPrintLines(my_session, 'forward_position')
   
    discrim['correctrejection_trials'] = reject
    discrim['falsepositive_trials'] = fp
    discrim['licks'] = lick
    discrim['go_position'] = go
    discrim['nogo_position'] = nogo
    
    return discrim
    

def saveMatStruct(dictOut, outPath, ID, sessionType, date):
    
   # the path to the mouse specific folder
    savePath = outPath + '/' + ID + '/'
     
    # create the mouse specific folder if it does not already exist
    if not os.path.exists(os.path.dirname(savePath)):
        try:
            os.makedirs(os.path.dirname(savePath))
        except OSError as exc: # Guard against race condition
            if exc.errno != errno.EEXIST:
                raise
 
    #save the dictionary as a matlab structure in the mouse folder
    sio.savemat(savePath + sessionType + '_' + date + '.mat',{'behavioural_data':dictOut}) 


txtFiles = getTxtFiles(fPath)
print(len(txtFiles))
for txtFile in txtFiles:
  
    try:
        runWorkflow(txtFile, outPath)
    except:
        print(txtFile)

        
    

#
    

    
    
    
    
    
    
    
    
    #np.set_printoptions(threshold=np.nan)     
    
    
    
    
    
    
