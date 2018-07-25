function taskSession = getSensoryStim(inSession)

times = inSession.times;

taskSession.motor_start = times.motor_forward;
taskSession.motor_atWhisk = times.stim_interval;
taskSession.motor_back = times.motor_backward;
taskSession.motor_atOrigin = times.trial_start;

[stim_position, stim_speed] = getStimulusInfo(inSession);
taskSession.stim_position = stim_position;
taskSession.stim_speed = stim_speed;