from pyControl.utility import *
import hardware_definition as hw

#-------------------------------------------------------------------------------------
# State machine definition.
#-------------------------------------------------------------------------------------

# States and events.

states = ['wait_epoch',
          'rew_epoch']

events = ['session_timer',
          'reward_dur',
          'left_poke_in',
          'left_poke_out',
          'right_poke_in',
          'right_poke_out',
          'rew_off',
          'no_rew',
          'opto_time',
          'start_rew'
          ]

initial_state = 'wait_epoch'

# Variables.

#Task variables
v.session_duration = 30 * minute
v.rew_side = 0

#data analysis variables
v.n_pokes = 0
v.pokes_dur = []
v.pokes_times = []
v.opto_on = True

#reward variables
v.rew_go = 1
v.rew_int = 2 #s
v.rew_counter = 0
v.reward_dur_0 = 200 # ms
v.reward_dur_1 = 200 # ms

v.opto_dur = sample_without_replacement([150, 200, 250, 300, 350, 400, 450, 500, 550, 600, 650, 700, 750, 800, 850, 900, 950, 1000])
v.delay = sample_without_replacement([10, 15, 20, 25, 30, 35])

# Run start and stop behaviour.

def run_start():
    set_timer('session_timer', v.session_duration)
    hw.houselight.on()
    if v.rew_side == 0:
        hw.left_poke.LED.on()
    else:
        hw.right_poke.LED.on()

def run_end():
    hw.off() # Turn off hardware outputs.

# State & event dependent behaviour.    

def wait_epoch(event):
    if event == 'left_poke_in':
        if (v.rew_side) == 0 and (v.rew_go == 1):
            goto_state('rew_epoch')
    elif event == 'right_poke_in':
        if (v.rew_side == 1) and (v.rew_go == 1):
            goto_state('rew_epoch')


def rew_epoch(event):
    if event == 'entry':
        v.rew_counter+=1
        print('Number of rewards delivered: '+str(v.rew_counter))
        print('Number of pokes: '+str(v.n_pokes))
        set_timer('no_rew', v.rew_int*second)
        v.rew_go = 0
        if v.rew_side == 0:
            set_timer('rew_off', v.reward_dur_0*ms)
            hw.left_poke.SOL.on()
        else:
            set_timer('rew_off', v.reward_dur_1*ms)
            hw.right_poke.SOL.on()
    elif event == 'rew_off':
        hw.left_poke.SOL.off()
        hw.right_poke.SOL.off()
        goto_state('wait_epoch')

def all_states(event):
    if event == 'session_timer':
        stop_framework() # End session
    elif event == 'no_rew':
        v.rew_go = 1
        if v.in_poke == 1:
            goto_state('rew_epoch')
    elif event == 'left_poke_in':
        if v.rew_side == 0:
            v.in_poke = 1
            v.pokes_times.append(get_current_time())
    elif event == 'right_poke_in':
        if v.rew_side == 1:
            v.in_poke = 1
            v.pokes_times.append(get_current_time())
    elif event == 'left_poke_out':
        if v.rew_side == 0:
            v.in_poke = 0
            v.current_dur = get_current_time()-v.pokes_times[v.n_pokes]
            v.pokes_dur.append(v.current_dur)
            v.n_pokes+=1
    elif event == 'right_poke_out':
        if v.rew_side == 1:
            v.in_poke = 0
            v.current_dur = get_current_time()-v.pokes_times[v.n_pokes]
            v.pokes_dur.append(v.current_dur)
            v.n_pokes+=1
    elif event == 'opto_time':
        print('LED off')
        hw.opto_led.off()