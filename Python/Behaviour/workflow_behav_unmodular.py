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

txtFiles = []

# find all the text files in fPath
for root, dirs, files in os.walk(fPath):
    for file in files:
        if file.endswith(".txt"):       
           txtFiles.append(os.path.join(root, file))


for txtFile in txtFiles:
        
    my_session = pc.Session(txtFile, False)
    
    ID = my_session.subject_ID
    
    my_session.events # List of events and state entries as named tuples of timestamp, event name
    
    my_session.times # Dictionary of the times when each event and state entry occured
    
    my_session.print_lines # List of all the lines output by print statement
     
    np.set_printoptions(threshold=np.nan)
    
    
    #set task to 0 if habituation session; 1 if recognition task session; 2 if discrimination task
    if 'habituation' in my_session.experiment_name:
        sessionType = 'habituation'
        task = 0
    elif 'training' in my_session.experiment_name:
        if 'position' in my_session.experiment_name:
            sessionType = 'training_position'
            task = 2
        else:     
            sessionType = 'training'
            task = 1
    else:
        raise ValueError('Could not assign task to text file %s' %my_session.experiment_name)
    

    
    dictOut = {}
    
    if task == 0:
    
        dictOut['running_forward'] =  my_session.times['going_forward']
        dictOut['licks'] =  my_session.times['lick_event']
        
        #lines below are to extract a print and its timings (eg water) from my_session.printlines
        waterList = []
        
        for line in my_session.print_lines:
          if (line.split()[1]) == 'water':
            value = line.split()[0]
            waterList.append(float(value))
        dictOut['water_delivered'] = waterList
    
    
    elif task ==1:
        
        
        dictOut['running_forward'] =  my_session.times['going_forward']
        dictOut['licks'] =  my_session.times['lick_event']
        
        correct_trials_list = []
        for line in my_session.print_lines:
          if (line.split()[1]) == 'correct':
            correct_trials_list.append(line.split()[0])
    
        dictOut['correct_trials'] = correct_trials_list
        
        missed_trials_list = []
        for line in my_session.print_lines:
          if (line.split()[1]) == 'missed':
            missed_trials_list.append(line.split()[0])
            
        dictOut['missed_trials'] = missed_trials_list
    
        false_positives_list = []
        for line in my_session.print_lines:
          if (line.split()[1]) == 'false_positive':
            false_positives_list.append(line.split()[0])
       
        dictOut['falsepositive_trials'] = false_positives_list
    
    elif task == 2:
        
        dictOut['running_forward'] =  my_session.times['going_forward']
        dictOut['licks'] =  my_session.times['lick_event']
        
        #lines below are to extract a print and its timings (eg water) from my_session.printlines
        waterList = []
        
        for line in my_session.print_lines:
          if (line.split()[1]) == 'waterON':
            value = line.split()[0]
            waterList.append(float(value))
        dictOut['water_delivered'] = waterList
    
            
    # find whether go position is forward or backwards by splitting the go position
    # string on the value '1' indicating the go position
    
        for line in my_session.print_lines:
           if 'correct position is' in line:
               split1 = (line.split('1',1)[1])
               if 'is forward' in split1:
                   go_pos = 1
               elif 'is backward' in split1:
                   go_pos  = 0
               else:
                   raise ValueError ('failed to find go position value')
               
        
        correct_trials_list = []
        for line in my_session.print_lines:
          if (line.split()[1]) == 'correct':
            correct_trials_list.append(float(line.split()[0]))
    
        dictOut['correct_trials'] = correct_trials_list
        
        missed_trials_list = []
        for line in my_session.print_lines:
          if (line.split()[1]) == 'missed' or (line.split()[1]) == 'too':
            missed_trials_list.append(float(line.split()[0]))
            
        dictOut['missed_trials'] = missed_trials_list
    
        correct_rejections_list = []
    
        for line in my_session.print_lines:
          if (line.split()[1]) == 'rejection':
            correct_rejections_list.append(float(line.split()[0]))
    
        dictOut['correctrejection_trials'] = correct_rejections_list
    
        false_positives_list = []
        for line in my_session.print_lines:
          if (line.split()[1]) == 'false_positive':
             
            false_positives_list.append(float(line.split()[0]))

        dictOut['falsepositive_trials'] = false_positives_list
    
        licks_list = []
        
        for line in my_session.print_lines:
          if (line.split()[1]) == 'lick':
            licks_list.append(line.split()[0])
    
        dictOut['licks'] = licks_list
    
        go_positions_list = []
        if go_pos == 1:
            for line in my_session.print_lines:
              if (line.split()[1]) == 'forward_position':
                go_positions_list.append(float(line.split()[0]))
    
    
        elif go_pos == 0:
            for line in my_session.print_lines:
              if (line.split()[1]) == 'backward_position':
                go_positions_list.append(line.split()[0])
                
        dictOut['go_position'] = go_positions_list
        
    
        nogo_positions_list = []
    
        if go_pos == 1:
            for line in my_session.print_lines:
              if (line.split()[1]) == 'backward_position':
                nogo_positions_list.append(float(line.split()[0]))
    
        elif go_pos == 0:
            for line in my_session.print_lines:
              if (line.split()[1]) == 'forward_position':
                nogo_positions_list.append(float(line.split()[0]))
                
        dictOut['nogo_position'] = nogo_positions_list
    
    # get the date that the session was carried out and use in file name
    date = my_session.datetime_string.split()[0]
    
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
    #
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
