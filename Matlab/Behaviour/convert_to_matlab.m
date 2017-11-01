%script to convert .txt data obtained through python into a matlab array.
% run this first section of the code only to save behav data as a
% matlab variable.

clear all
close all

mouse='VIP394a';
session_date='20171011';
task = 0; %set to 0 for habituation sessions, 1 for recognition task, 2 for discrimination task

if task == 0
    running_forward = importdata('going_forward.txt');
    licks = importdata('lick_event.txt');
    water_delivered = importdata('water.txt');
    save (['/Users/mariangelapanniello/Desktop/behav_data/' mouse '/matlab_data/habituation/' mouse '_' session_date 'speed.mat'],'mouse','session_date','running_forward','licks', 'water_delivered');

elseif task == 1
    correct_trials = importdata('correct_trial.txt');
    missed_trials = importdata('missed_trial.txt');
    falsepositive_trials = importdata('false_positive.txt');
    save (['/Users/mariangelapanniello/Desktop/behav_data/' mouse '/matlab_data/training/' mouse '_' session_date 'speed.mat'],'mouse','session_date','correct_trials','missed_trials', 'falsepositive_trials');

elseif task == 2
    correct_trials = importdata('correct_trial.txt');
    missed_trials = importdata('missed_trial.txt');
    falsepositive_trials = importdata('false_positive.txt');
    correctrejection_trials = importdata('correct_rejection.txt');
    go_position = importdata('go_positions.txt');
    nogo_position = importdata('nogo_positions_list.txt');
    licks = importdata('licks.txt');
    save (['/Users/mariangelapanniello/Desktop/behav_data/' mouse '/matlab_data/training/' mouse '_' session_date 'speed.mat'],'mouse','session_date','correct_trials','missed_trials', 'falsepositive_trials', 'correctrejection_trials','go_position','nogo_position','licks');

end

display('done!')