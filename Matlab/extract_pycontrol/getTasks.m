function allSessions = getTasks(txts, pcas)


% this function takes the place of workflow_behav.py. It parses the output
% of txt file to be yield parameters relevant to the task
% it also adds the velocity

% a cell of structures containing all behaviour
allSessions = {};

for i = 1:length(txts)
    
    
    fPath = [txts{i}.folder '/' txts{i}.name];
    
    inSession = pyReader(fPath);
    
    % non pycontrol txt files should return empty list
    if isempty(inSession)
        continue
    end
    
    if length(txts) == length(pcas)
        running = getAnalogue([pcas{i}.folder '/' pcas{i}.name]);
    else
        running = [];
        disp('cant find all pcas to match txt files, no running info will be returned, a fix is on the todo list')
    end
    
    outSession = {};
    
    times = inSession.times;
    
    % add the info required for each task
    
    IDinf = split(inSession.subject_ID, '_');
    
    if length(IDinf) > 1
        ID = IDinf{1};
        area = IDinf{2};
    else
        ID = IDinf{1};
        area = [];
    end
    
    dateInf = split(inSession.date, ' ');
    date = datestr(dateInf{1}, 'yyyy-mm-dd');
    
    outSession.ID = ID;
    outSession.date = date;
    outSession.area = area;
    outSession.task = inSession.task;
    
    outSession.running = running;
    outSession.TTLs = getTTL(inSession);
    
    % add the important info to extract for the sensory stim task
    if strcmp(inSession.task, 'sensory_stimulation')
        
        outSession.motor_start = times.motor_forward;
        outSession.motor_atWhisk = times.stim_interval;
        outSession.motor_back = times.motor_backward;
        outSession.motor_atOrigin = times.trial_start;
        
        [stim_position, stim_speed] = getStimulusInfo(inSession);
        outSession.stim_position = stim_position;
        outSession.stim_speed = stim_speed;
        
    end
    
    allSessions{end+1} = outSession;
    
    
end




