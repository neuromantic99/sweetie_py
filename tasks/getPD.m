function taskSession = getPD(inSession)

times = inSession.times;

taskSession.motor_start = times.motor_forward;
taskSession.motor_atWhisk = times.stim_interval;
taskSession.motor_back = times.motor_backward;
taskSession.motor_atOrigin = times.trial_start;

taskSession.licks = times.lick_event;

[taskSession.correct, taskSession.missed, taskSession.correct_rejection, ...
 taskSession.false_positive, taskSession.too_soon] = getTrialType(inSession);

% creates a readable variable with a list of ordered trial outcomes
taskSession.trial_type = concatTrials(taskSession);

taskSession.waterON = getWaterOn(inSession);



