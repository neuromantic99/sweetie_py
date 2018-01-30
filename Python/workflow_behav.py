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

fPath = '/media/jamesrowland/DATA/RawData/ANA'
outPath = '/home/jamesrowland/Documents/ProcessedData/behaviour/ANA'


def initialise(fPath):
    txtFiles = getTxtFiles(fPath)

    for txtFile in txtFiles:
        print(txtFile)
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
    [ID, date, sessionType, go_pos, maxi] = getMetaData(my_session)
        
    # create the dictionary 'dictOut' which will be saved as a .mat file
    # this requires running the appropriate functions for the type of training
    # and merging the individual dictionaries using the line z = {**x, **y}

    if sessionType == 'imaging_stimulation':
        imInfo = getImagingInfo(my_session)
        dictOut = imInfo
        

    elif sessionType == 'imaging_discrimination' or sessionType == 'imaging_detection':
        imInfo = getImagingInfo(my_session)        
        tS = imInfo['tStart'] #start time of the imaging

        training = getTraining(my_session)
       
        # function that subtracts the start time of imaging from other times 
        norm =  lambda t: [x - tS for x in t]
        
        # subtract tstart from times in dictionary
        training = {key: norm(val) for key, val in training.items()}
        
        dictOut = {**training, **imInfo}
        
    elif sessionType == 'imaging_flavour':
        flavourInfo = getFlavourInfo(my_session)
        dictOut = flavourInfo
        
        
      

    else:
        # get basic information required in all behaviours in the BSB 
        basicInfo = getBasicInfo(my_session)
        
        if 'habituation' in sessionType:
            dictOut = basicInfo
        elif sessionType == 'recognition':
            training = getTraining(my_session)
            dictOut = {**basicInfo, **training}
        elif sessionType == 'discrimination':
            training = getTraining(my_session)
            discrim = getDiscrimination(my_session, go_pos)
            dictOut = {**basicInfo, **training, **discrim}
            
       
    # add the metadata to the dictionary
    dictOut['ID'] = ID
    dictOut['date'] = date
    dictOut['sessionType'] = sessionType
    dictOut['session_length'] = maxi

    #sometimes the mouse doesnt run at all which will return None value
    #in the dictionary, scipy cannot make this into a mat, so replace it
    #with a suitable string
    for key, value in dictOut.items():

         if value is None:
             dictOut[key] = 'No Values Found'

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
    ID = my_session.subject_ID.split('_')[0]
                 
    # get the date that the session was carried out and use in file name
    date = my_session.datetime_string.split()[0]
    
    go_pos = 'None'
    
    name = my_session.experiment_name
    try:
        maxi = max([float(line.split()[0]) for line in my_session.print_lines])
    except ValueError:
        maxi = 0
        
    if '2p' in name:
        if 'whiskerstim' in name or 'naive_norun' in name:
            sessionType = 'imaging_stimulation'
        
        elif 'trained_water' in name or 'gonogo' in name:
            sessionType = 'imaging_discrimination'
            
        elif 'detection' in name:
            sessionType = 'imaging_detection'
            
            
        elif 'flavour' in name:
            sessionType = 'imaging_flavour'
            
            # leaving out the go-pos for now, check later
            #go_pos = getGoPos(my_session)
        else:
            raise ValueError('unknown imaging behaviour %s' %my_session.file_name)
             
    
    # find the task the mouse did corresponding to the text file.
    # call the function relevant to that task 
    elif 'habituation' in name:
        if 'firstday'  in name:
            sessionType = 'habituation_fd'
        else:
            sessionType = 'habituation'
        
       
        
    elif 'training' in my_session.experiment_name:
        if 'position' in my_session.experiment_name:
            sessionType = 'discrimination'      
            go_pos = getGoPos(my_session)
        else:     
            sessionType = 'recognition'
            
  
    else:
        raise ValueError('Could not assign task to text file %s' % my_session.file_name)

    return ID, date, sessionType, go_pos, maxi

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
               raise ValueError ('failed to find go position value in file %s' %(my_session.file_name))
   
    if foundGo == False:
        raise ValueError ('failed to find GO position in file %s' % my_session.file_name)
       
    return go_pos
    
   
def searchPrintLines(my_session, I):
    
    '''
    function that searches through the lines to see if the first word
    after the time is the variable 'I'. 
    returns a list of the times (ms) that the string was printed
    during behaviour  
    '''
    
    l = [line.split()[0] for line in my_session.print_lines if line.split()[1] == I]
    
    return [float(val) for val in l]
        
    
def getBasicInfo(my_session):
    
    basicInfo = {}
    # couldnt use MSPL as water and waterON are recorded 
    basicInfo['water_delivered'] = [float(line.split()[0]) for line in my_session.print_lines if 'water' in line]
    basicInfo['running_forward'] =  my_session.times.get('going_forward')
    basicInfo['licks'] =  my_session.times.get('lick_event')    
   
    return basicInfo


def getTraining(my_session):
        
    training = {}

    training['correct_trials'] = searchPrintLines(my_session, 'correct')
    training['missed_trials']  = searchPrintLines(my_session, 'missed')
    training['falsepositive_trials'] =  searchPrintLines(my_session, 'false_positive')
    training['correctrejection_trials'] = searchPrintLines(my_session,'rejection')
    
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
        
    try:
        tS = my_session.times.get('TTL_in')[0]
    except:
        tS = []
        print('could not find a trigger for the imaging session %s ' %my_session.file_name)

    imInfo['licks'] =  searchPrintLines(my_session, 'lick')
    imInfo['water_delivered'] = searchPrintLines(my_session, 'waterON')
    imInfo['running_forward'] =  my_session.times.get('running mouse')
    imInfo['running_backward'] = my_session.times.get('moonwalking mouse')
    #couldnt use 'searchPrintLines' for this because of the conflicting for 'going'
    imInfo['motor_start'] = [float(line.split()[0]) for line in my_session.print_lines if 'going forward' or 'motor at whiskers' in line]
    imInfo['initial_trials'] = [float(line.split()[0]) for line in my_session.print_lines if 'end of initial trial' in line]
    
    # function that subtracts the start time of imaging from other times 

    norm = lambda t: [x - tS for x in t]

    # subtract tstart from times in dictionary
    
    imInfo = {key: norm(val) for key, val in imInfo.items() if type(val) is list or type(val) is np.ndarray}

    # save tStart for future calculations
    imInfo['tStart'] = tS
       
    #get the area, found after the underscore in the ID
    name = my_session.subject_ID
    if 'area' in name:
        imInfo['area'] = my_session.subject_ID.split('_')[1]
    else:
        pass

    return imInfo


def getFlavourInfo(my_session):
    flavInfo = {}
    flavInfo['running_forward'] = my_session.times.get('going_forward')
    flavInfo['licks'] = my_session.times.get('lick_event')
    
    flavInfo['flavourA'] = [float(line.split()[0]) for line in my_session.print_lines if len(line.split()) > 2 and line.split()[2] == 'A']
    flavInfo['flavourB'] = [float(line.split()[0]) for line in my_session.print_lines if len(line.split()) > 2 and line.split()[2] == 'B']
    
    name = my_session.subject_ID
    if 'area' in name:
        flavInfo['area'] = my_session.subject_ID.split('_')[1]
    else:
        pass

   
    return flavInfo
    


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
    
    # need information about the area to prevent overwriting in cases where more than 
    # one behaviour has been recorded on the same day during imaging
    
    if 'area' in dictOut:
        area = dictOut['area']
    else:
        area = ''

    #save the dictionary as a matlab structure in the mouse folder
    sio.savemat(savePath + sessionType + '_' + date + area + '.mat',{'behavioural_data':dictOut}) 



initialise(fPath)    
    



















    


    
    

