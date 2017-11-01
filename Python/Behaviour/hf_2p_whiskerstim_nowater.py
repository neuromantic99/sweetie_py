from pyControl.utility import *
import hardware_definition as hw



#-------------------------------------------------------------------------------------
# State machine definition.
#-------------------------------------------------------------------------------------

# States and events.

states = ['TTL_wait', 'scanning', 'stim_epoch']

events = ['session_timer',
		 'encoder_event',
		 'encoder_A',
		 'encoder_B',
		 'rotation_lapsed',
		 'stepper_backpause',
		 'stim_pause',
		 'forward_pause',
		 'stim_off',
		 'lick_event',
		 'reward',
		 'period_off',
		 'trial',
		 'stepper_backlick',
		 'false_positive',
		 'cycle_complete',
		 'encoder_check_timer',
         'going_forward',
         'going_backward',
         'speed_check',
         'TTL_in',
         'intro'
		 ]

initial_state = 'TTL_wait'



# Variables.
v.session_duration = 30 #minutes. NB MAKE SURE SESSION DURATION IS LONGER THAN SUM OF TRIALS IF MOUSE DOES ONLY FALSE POSITIVES
v.reward_time = 150 # 75 ms default
v.event_counter = 0
v.period = 5 #s
v.run_data = []
v.lick_data = []
v.correct_lick_data = []
v.motor_stim_onset_data = []
v.false_positive_data = []
v.stepper_frequency = 1500 #steps of 0.5ms for 1000 freq
v.stepper_degrees = 180
v.stepper_default = 1.8
v.stepper_forwardpause = 600 #pause closest to whiskers
v.stepper_backpause = 3 #02.84 #pause in between stim trials, in seconds
v.stepper_backlick = 4 #time at start of backpause during which the mouse has to lick without being a false positive, in seconds
v.stepper_counter = 100 #desired number of stimulation trials
v.stepper_timeon = 250 #time during which motor is on - the longer = longer distance covered
v.lick_window = 0 #window during which mouse can lick at backpause - if window >0, time window has ended
v.lick_penalty = 0 #if penalty==1, penalty time will be added to the backpause, because the mouse has done a false positive lick
v.A = 0
v.B = 0
v.lapsed = 1
v.lap_counter = 0
v.encoder_time_resolution = 100 # Time interval between checks of encoder position.
v.encoder_distance = hw.encoder.get_distance() # Distance moved by encoder.
v.movement_threshold = 30 # Set > 0 to only generate encoder movement events above a certain speed.
v.encoder_counter = 10 # Set number of 'going forward' events to trigger stim epoch
v.counter = 0
v.speed_check = 2 #seconds


# Run start and stop behaviour.
def run_start():
	set_timer('session_timer', v.session_duration*minute)
	print('session started')
	set_timer('encoder_check_timer', v.encoder_time_resolution * ms)
def run_end():
	hw.off() # Turn off hardware outputs.

# State & event dependent behaviour.

def TTL_wait(event):
	if event == 'TTL_in':
		set_timer('intro', 30*second)
		print('timer started')
	if event == 'intro':
		goto_state('stim_epoch') #remember to change hardware def

def scanning(event):
	if event =='entry' or event =='speed_check':
		print('speed_check_window')
		v.counter = v.encoder_counter
		set_timer('speed_check', v.speed_check * second)
	elif event == 'going_forward':
		print('forward')
		v.counter = v.counter-1
		if v.counter==0:
			disarm_timer('speed_check')
			goto_state('stim_epoch')
	elif event == 'going_backward':	
		print('backward')
		v.counter = v.counter+1
		if v.counter ==15:
			v.counter = 10




def stim_epoch(event): #stepper motor stimulation
	if (event == 'entry') or (event == "stepper_backpause"):
		hw.stepper.turn_for(v.stepper_frequency)
		#set_timer("stim_pause", ((1/v.stepper_frequency)*(v.stepper_degrees/v.stepper_default))*second)
		set_timer("stim_pause", 279.667)
		print('going forward')
	elif event == "stim_pause":
		hw.stepper.off()
		print('pause1')
		set_timer("forward_pause", v.stepper_forwardpause*ms)
	elif event =="forward_pause":
		hw.stepper.turn_back(v.stepper_frequency)
		#set_timer("stim_off", ((1/v.stepper_frequency)*(v.stepper_degrees/v.stepper_default))*second)
		set_timer("stim_off", 279.667)
		print('going back')
	elif event =="stim_off":
		set_timer("stepper_backpause", v.stepper_backpause *second)
		hw.stepper.off()
		print('pause2')
		v.stepper_counter = v.stepper_counter-1
		print(v.stepper_counter)
	if v.stepper_counter == 0:
		stop_framework() 



def all_states(event):
    # When encoder check timer elapses, set timer again and read encoder position
    # If encoder has moved forward/backward more than specified threshold, publish 
    # going_forward/going_backward event.
	if event == 'encoder_check_timer':
		set_timer('encoder_check_timer', v.encoder_time_resolution)
		new_encoder_distance = hw.encoder.get_distance() 
		distance_moved = v.encoder_distance - new_encoder_distance
		if distance_moved < -v.movement_threshold:
		    publish_event('running mouse')
		    print('running mouse')
		elif distance_moved > v.movement_threshold:
		    publish_event('moonwalking mouse')
		    print('moonwalking mouse')
		v.encoder_distance = new_encoder_distance

	elif event == 'lick_event':
		print('lick')
 
	elif event == 'session_timer':
		stop_framework() # End session


"""def turn_for(delay): )
	hw.direc.off() #set direction forward
	hw.step.pulse(1/(2*delay))

def turn_back(delay): 
	hw.direc.on() #set direction back
	hw.step.pulse(1/(2*delay))"""