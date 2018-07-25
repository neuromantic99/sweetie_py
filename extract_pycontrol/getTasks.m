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
    
    
    
    % have another task called sens_stim_baseline which needs the same info
    % as normal sensory stimulation
    if strcmp(inSession.task, 'sens_stim_baseline')
        inSession.task = 'sensory_stimulation';
    end
    
    outSession.ID = ID;
    outSession.date = date;
    outSession.area = area;
    outSession.task = inSession.task;
    
    outSession.running = running;
    outSession.TTLs = getTTL(inSession);
    
    % add the important info to extract for the sensory stim task
    if strcmp(inSession.task, 'sensory_stimulation')
        taskStruct = getSensoryStim(inSession);
        
    taskStruct = {};
    % add the important info for position discrimination task
    elseif strcmp(inSession.task, 'pd_1') || strcmp(inSession.task, 'pd_2')
        taskStruct = getPD(inSession);
    end
    
    tfNames = fieldnames(taskStruct);
    
    % append the task information to the final behavioural structure
    for i = 1:length(tfNames)
        tfn = tfNames{i};
        outSession.(tfn) = taskStruct.(tfn);
    end
            
    
    
    
    
    allSessions{end+1} = outSession;
    
    
end




