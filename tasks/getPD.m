function taskSession = getPD(inSession)

times = inSession.times;

taskSession.motor_start = times.motor_forward;
taskSession.motor_atWhisk = times.stim_interval;
taskSession.motor_back = times.motor_backward;
taskSession.motor_atOrigin = times.trial_start;

taskSession.licks = times.lick_event;

taskSession.trialType = getTrialType(inSession);

taskSession.waterON = getWaterOn(inSession);



