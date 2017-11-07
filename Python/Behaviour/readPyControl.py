import os
import numpy as np

import sys
np.set_printoptions(threshold=sys.maxsize)

from datetime import datetime, date
from collections import namedtuple
import pickle

Event = namedtuple('Event', ['time','name'])

#----------------------------------------------------------------------------------
# Session class
#----------------------------------------------------------------------------------

class Session():
    '''Import data from a pyControl file and represent it as an object with attributes:
      - file_name
      - experiment_name
      - task_name
      - subject_ID
          If argument int_subject_IDs is True, suject_ID is stored as an integer,
          otherwise subject_ID is stored as a string.
      - datetime
          The date and time that the session started stored as a datetime object.
      - datetime_string
          The date and time that the session started stored as a string of format 'YYYY-MM-DD HH:MM:SS'
      - events
          A list of all framework events and state entries in the order they occured. 
          Each entry is a namedtuple with fields 'time' & 'name', such that you can get the 
          name and time of event/state entry x with x.name and x.time respectively/
      - times
          A dictionary with keys that are the names of the framework events and states and 
          corresponding values which are Numpy arrays of all the times (in milliseconds since the
           start of the framework run) at which each event occured.
      - print_lines
          A list of all the lines output by print statements during the framework run, each line starts 
          with the time in milliseconds at which it was printed.
    '''

    def __init__(self, file_path, int_subject_IDs=True):

        # Load lines from file.
        
        # Had to change import encoding to utf-8 to satisfy my console 
        with open(file_path, 'r', encoding = 'utf-8') as f:
                  
            all_lines = [line.strip() for line in f.readlines() if line.strip()]

            
            
            
        # utf-8 encoding generates weird string at start of document which needs to be removed
      
        all_lines = [line.replace(u'\ufeff', '') for line in all_lines]
        
        # Extract and store session information.
        self.file_name = os.path.split(file_path)[1]
        

        info_lines = [line[2:] for line in all_lines if line[0]=='I']
    

        self.experiment_name = next(line for line in info_lines if 'Experiment name' in line).split(' : ')[1]
        self.task_name       = next(line for line in info_lines if 'Task name'       in line).split(' : ')[1]
        subject_ID_string    = next(line for line in info_lines if 'Subject ID'      in line).split(' : ')[1]
        datetime_string      = next(line for line in info_lines if 'Start date'      in line).split(' : ')[1]

        if int_subject_IDs: # Convert subject ID string to integer.
            self.subject_ID = int(''.join([i for i in subject_ID_string if i.isdigit()]))
        else:
            self.subject_ID = subject_ID_string

        self.datetime = datetime.strptime(datetime_string, '%Y/%m/%d %H:%M:%S')
        self.datetime_string = self.datetime.strftime('%Y-%m-%d %H:%M:%S')

        # Extract and store session data.

        state_IDs = eval(next(line for line in all_lines if line[0]=='S')[2:])
        event_IDs = eval(next(line for line in all_lines if line[0]=='E')[2:])

        ID2name = {v: k for k, v in {**state_IDs, **event_IDs}.items()}

        data_lines = [line[2:].split(' ') for line in all_lines if line[0]=='D']

        self.events = [Event(int(dl[0]), ID2name[int(dl[1])]) for dl in data_lines]

        self.times = {event_name: np.array([ev.time for ev in self.events if ev.name == event_name])  
                      for event_name in ID2name.values()}

        self.print_lines = [line[2:] for line in all_lines if line[0]=='P']


#----------------------------------------------------------------------------------
# Experiment class
#----------------------------------------------------------------------------------

class Experiment():
    def __init__(self, folder_path, int_subject_IDs=True, rebuild_sessions=False):
        '''

        '''

        self.folder_name = os.path.split(folder_path)[1]
        self.path = folder_path

        # Import sessions.

        self.sessions = []
        if not rebuild_sessions:
            try: # Load sessions from saved sessions.pkl file.
                with open(os.path.join(self.path, 'sessions.pkl'),'rb') as sessions_file:
                    self.sessions = pickle.load(sessions_file)
                print('Saved sessions loaded from: sessions.pkl')
            except IOError:
               pass
        
        print(self.sessions.file_name)
        old_files = [session.file_name for session in self.sessions]
        files = os.listdir(self.path)
        new_files = [f for f in files if f[-4:] == '.txt' and f not in old_files]

        if len(new_files) > 0:
            print('Loading new data files..')
            for file_name in new_files:
                try:
                    self.sessions.append(Session(os.path.join(self.path, file_name), int_subject_IDs))
                except Exception as error_message:
                    print('Unable to import file: ' + file_name)
                    print(error_message)

        # Assign session numbers.

        self.subject_IDs = list(set([s.subject_ID for s in self.sessions]))
        self.n_subjects = len(self.subject_IDs)

        self.sessions.sort(key = lambda s:s.datetime_string + str(s.subject_ID))
        
        self.sessions_per_subject = {}
        for subject_ID in self.subject_IDs:
            subject_sessions = self.get_sessions(subject_ID)
            for i, session in enumerate(subject_sessions):
                session.number = i+1
            self.sessions_per_subject[subject_ID] = subject_sessions[-1].number

    def save(self):
        '''Save all sessions as .pkl file.'''
        with open(os.path.join(self.path, 'sessions.pkl'),'wb') as sessions_file:
            pickle.dump(self.sessions, sessions_file)
        
    def get_sessions(self, subject_IDs='all', when='all'):
        '''Return list of sessions which match specified subject ID and time range.
        '''
        if subject_IDs == 'all':
            subject_IDs = self.subject_IDs
        if not isinstance(subject_IDs, list):
            subject_IDs = [subject_IDs]


        if when == 'all': # Select all sessions.
            when_func = lambda session: True

        elif isinstance(when, int):
            if when < 0: # Select most recent 'when' sessions.
                when_func = lambda session: (session.number > 
                    self.sessions_per_subject[session.subject_ID] + when)
            else: 
                when_func = lambda session: session.number == when

        elif when[1] == ... : # Select a range..
            assert type(when[0]) == type(when[2]), 'Start and end of time range must be same type.'
            if type(when[0]) == int: # .. of session numbers.
                when_func = lambda session: when[0] <= session.number <= when[2]
            else: # .. of dates.
                when_func = lambda session: _toDate(when[0]) <= session.datetime.date() <= _toDate(when[2])
        
        else: # Select specified..
            assert all([type(when[0]) == type(w) for w in when]), "All elements of 'when' must be same type."
            if type(when[0]) == int: # .. session numbers.
                when_func = lambda session: session.number in when
            else: # .. dates.
                dates = [_toDate(d) for d in when]
                when_func = lambda session: session.datetime.date() in dates

        valid_sessions = [s for s in self.sessions if s.subject_ID in subject_IDs and when_func(s)]
        
        if len(valid_sessions) == 1: 
            valid_sessions = valid_sessions[0] # Don't return list for single session.
        return valid_sessions       


def _toDate(d): # Convert input to datetime.date object.
    if type(d) is str:
        try:
            return datetime.strptime(d, '%Y-%m-%d').date()
        except ValueError:
            print('Unable to convert string to date, format must be YYYY-MM-DD.')
            raise ValueError
    elif type(d) is datetime:
        return d.date()
    elif type(d) is date:
        return d
    else:
        raise ValueError
        
        
#==============================================================================
# fPath = '/Users/James/Google Drive/BehaviouralData/VIP394a/area01/'
# fName = 'VIP394a-2017-10-06-112449.txt'
# 
# x = Session(fPath + fName)
# with open(fPath + 'sessions.pkl', 'wb') as f:
#     pickle.dump(x, f)
# 
# Experiment(fPath)
# 
# 
#==============================================================================





























