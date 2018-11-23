import numpy as np
import matplotlib.pyplot as plt
import glob
import os
import csv
import utils.data_import as di

class opto_stim_import():
    def __init__(self, ID, path, date, task_str = None):
        '''
        class to parse relevant opto_stim task information to a python object
        inputs:
        ID - the ID of the mouse 
        path - path to the behavioural txt files, must point to directory of date folders containing txt files 
        date - the date of interest must be in same format as folders in path
        task_str - allows user to specify a string if there is more than 1 txt file for a single mouse on 1 day
        
        '''
        self.ID = ID
        self.path = path
        self.date = date
        self.date_path = os.path.join(path,date)
        self.task_str = task_str

        self.get_files()
        
        #use data_import to build session do not add this to object 
        self.session = di.Session(self.txt_file)
        self.print_lines = self.session.print_lines
        
        self.trial_outcome()
        self.num_trials = len(self.outcome)
        
        self.get_current()

        self.get_licks()
        
        self.dprime()
        
        self.autoreward()

        
        
    def get_files(self):
        '''get text files for ID for given date in path'''
        os.chdir(self.date_path)
        txt_files = [file for file in glob.glob("*.txt") if self.ID in file]
        
        # filter txt files if task_str given
        if self.task_str:
            txt_files = [file for file in txt_files if self.task_str in file]
        
        #make sure haven't returned more than 1 txt file
        assert len(txt_files) == 1, 'error finding txt files'
 
        self.txt_file = txt_files[0]

    def trial_outcome(self):
        '''creates list of strings of trial outcomes and the times they occured'''
        outcome = []
        trial_time = []
        for line in self.print_lines:
            if 'earned_reward' in line:
                time = float(line.split(' ')[0])
                trial_time.append(time)
                outcome.append('hit')
            elif 'missed trial' in line:
                time = float(line.split(' ')[0])
                trial_time.append(time)
                outcome.append('miss')            
            elif 'correct rejection' in line:
                time = float(line.split(' ')[0])
                trial_time.append(time)
                outcome.append('cr')
            elif 'false positive' in line:
                time = float(line.split(' ')[0])
                trial_time.append(time)
                outcome.append('fa')
                
        self.trial_time = trial_time
        self.outcome = outcome
    
    
    def get_current(self):
        '''gets the LED current on each trial'''
        self.LED_current = [line.split(' ')[4] for line in self.print_lines if 'LED current is' in line and 'now' not in line]
        print(self.LED_current)
        print(self.outcome)
        #assert len(self.LED_current) == self.num_trials, 'Error, num LED currents is {} and num trials is {}'.format(len(self.LED_current), self.num_trials)
        
        
    
    def dprime(self):
        '''get the value of online dprime calculated in the task'''
        self.online_dprime = [float(line.split(' ')[3]) for line in self.print_lines if 'd_prime is' in line]
       
    
    def get_licks(self):
        '''gets the lick times normalised to the start of each trial'''
        licks = self.session.times.get('lick_1')
        
        self.binned_licks = []
        
        for i,t in enumerate(self.trial_time):
            t_start = t
            if i == self.num_trials-1:
                # arbitrary big number to prevent index error on last trial
                t_end = 10e100
            else:
                t_end = self.trial_time[i+1]
                
            #find the licks occuring in each trial    
            trial_IND = np.where((licks>t_start) & (licks<t_end))[0]
            
            #normalise to time of trial start
            trial_licks = licks[trial_IND] - t_start

            self.binned_licks.append(trial_licks)

            
    def autoreward(self):
        '''detect if pycontrol went into autoreward state '''
        autoreward_times = self.session.times.get('auto_reward') 
        self.autorewarded_trial = []
        for i,t in enumerate(self.trial_time):
            t_start = t
            if i == self.num_trials-1:
                # arbitrary big number to prevent index error on last trial
                t_end = 10e100
            else:
                t_end = self.trial_time[i+1]


            is_autoreward = [a for a in autoreward_times if a >= t_start and a < t_end]
            if is_autoreward:
                self.autorewarded_trial.append(True)
            else:
                self.autorewarded_trial.append(False)
                
                
                
                
class merge_sessions():
    def __init__(self, ID, behaviour_path, LUT_path):
        '''
        class to merge all sessions from a mouse into single variables
        inputs: ID - the mouse of interest
                behaviour_path: path to directory of dates with behaviours
                LUT_path: path to the LUT detailing the names and order of behaviour txts for a mouse
        '''     
        
        self.ID = ID
        self.behaviour_path = behaviour_path
        self.LUT_path = LUT_path
        
        self.build_path_dict()
        
        self.merge()        
        
    def build_path_dict(self):
        #a dictionary containing the keys of mouse names and the paths to the txt files as vals
        path_dict = {}

        with open(self.LUT_path, 'r') as csvfile:
            LUTreader = csv.reader(csvfile, delimiter=',')
            for row in LUTreader:
                path_dict[row[0]] = row[1:]
                
        # the txt files for the mouse of interest
        try:
            self.mouse_txts = path_dict[self.ID]
        except:
            raise ValueError('mouse not present in behavioural LUT')
        
    def merge(self):  
        '''merge task info from seperate session into a single list'''
        self.outcome = []
        self.online_dprime = []
        self.binned_licks = [] 
        self.LED_current = []
        
        for txt in self.mouse_txts:
            #throw out blank cells
            if txt:
                date = self.extract_date(txt)
                # future refinement could super or sub this class
                t_session = opto_stim_import(self.ID, self.behaviour_path, date, task_str = txt)
                [self.outcome.append(x) for x in t_session.outcome]
                [self.online_dprime.append(x) for x in t_session.online_dprime]
                [self.binned_licks.append(x) for x in t_session.binned_licks]
                [self.LED_current.append(x) for x in t_session.LED_current]

                
    
    def extract_date(self, txt):
        '''clunky function to extract date directly from txt file name this may break at some point so check'''
        txt_split = txt.split('-')
        return '{0}-{1}-{2}'.format(txt_split[1], txt_split[2], txt_split[3])
    
    
    
