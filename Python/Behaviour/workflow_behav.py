import readPyControl as pc
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

fPath = '/home/jamesrowland/Documents/RawBehaviour/2p_behaviour/2017-10-18-hf_2p_whiskerstim_nowater'
outPath = '/home/jamesrowland/Documents/ProcessedData/behaviour/'



def runWorkflow(txtFile, outPath):

    #call Tom's behaviour module    
    
    my_session = pc.Session(txtFile, False)
  

    # get the meta data from the header of the txt file
    [ID, date, sessionType, go_pos] = getMetaData(my_session)
        
    # create the dictionary 'dictOut' which will be saved as a .mat file
    # this requires running the appropriate functions for the type of training
    # and merging the individual dictionaries using the line z = {**x, **y}
   
    if sessionType == 'imaging_stimulation':
        imInfo = getImagingInfo(my_session)
        dictOut = imInfo
        
    
    elif sessionType == 'imaging_discrimination':
        training = getTraining(my_session)
        imInfo = getImagingInfo(my_session)
        dictOut = {**training, **imInfo}

    else:
        # get basic information required in all behaviours in the BSB 
        basicInfo = getBasicInfo(my_session)
        
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
    
    name = my_session.experiment_name
    
    # find the task the mouse did corresponding to the text file.
    # call the function relevant to that task 
    if 'habituation' in name:      
        sessionType = 'habituation' 
    
    elif '2p' in name:
        if 'whiskerstim' in name:
            sessionType = 'imaging_stimulation'
        elif 'trained_water' in name:
            sessionType = 'imaging_discrimination'
            go_pos = getGoPos(my_session)
        else:
            raise ValueError('unknown imaging behaviour')
        
        
    elif 'training' in my_session.experiment_name:
        if 'position' in my_session.experiment_name:
            sessionType = 'discrimination'      
            go_pos = getGoPos(my_session)
        else:     
            sessionType = 'recognition'
    else:
        raise ValueError('Could not assign task to text file %s' % my_session.experiment_name)

        
        
            
             
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
        raise ValueError ('failed to find GO position in file %s' % my_session.subject_ID)
       
    return go_pos
    
    
   
def searchPrintLines(my_session, I):
    
    '''
    function that searches through the lines to see if the first word
    after the time is the variable 'I'. 
    returns a list of the times (ms) that the string was printed
    during behaviour  
    '''
    
    l = [line.split()[0] for line in my_session.print_lines if line.split()[1] == I]
    
    return l
        
    
def getBasicInfo(my_session):
    
    basicInfo = {}
    
    basicInfo['water_delivered'] = searchPrintLines(my_session, 'waterON')   
    basicInfo['running_forward'] =  my_session.times['going_forward']
    basicInfo['licks'] =  my_session.times['lick_event']    
   
    return basicInfo


        

def getTraining(my_session):
        
    training = {}

    training['correct_trials'] = searchPrintLines(my_session, 'correct')
    training['missed_trials']  = searchPrintLines(my_session, 'missed')
    training['falsepositive_trials'] =  searchPrintLines(my_session, 'false_positive')
    
    return training
    

def getDiscrimination(my_session, go_pos):
    
    discrim = {}
        
    discrim['correctrejection_trials'] = searchPrintLines(my_session,'rejection')
    discrim['falsepositive_trials'] = searchPrintLines(my_session, 'false_positive')
    discrim['licks']  = searchPrintLines(my_session, 'lick')

    if go_pos == 1:
        discrim['go_position']  =  searchPrintLines(my_session, 'forward_position')
        discrim['nogo_position'] =  searchPrintLines(my_session, 'backward_position')
    elif go_pos == 0:
        discrim['go_position'] = searchPrintLines(my_session, 'backward_position')
        discrim['nogo_position'] = searchPrintLines(my_session, 'forward_position')
  
    return discrim


def getImagingInfo(my_session):
    
    '''
    the behaviour under 2p is stored differently to in the bsb,
    thus a new function is required    
    '''
    
    imInfo = {}
    imInfo['running_forward'] =  my_session.times['running mouse']
    imInfo['running_backward'] = my_session.times['moonwalking mouse']
    
    #couldnt use 'searchPrintLines' for this because of the conflicting for 'going'
    imInfo['motor_start'] = [line.split()[0] for line in my_session.print_lines if 'going forward' in line]
     
    return imInfo
    
    
    









    

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

for txtFile in txtFiles:
    try:
        my_session = pc.Session(txtFile, False)
    except StopIteration:
        print('blank txt files in directory')
        continue
    
        #runWorkflow(txtFile, outPath)
    

        
    

#
    

    
    
    
    
    
    
    
    
    #np.set_printoptions(threshold=np.nan)     
    
    
    
    
    
    
