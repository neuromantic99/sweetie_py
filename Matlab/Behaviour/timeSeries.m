function imaging = timeSeries(imaging, behaviour)

% split the data by trial and generate list of string detailing
% the information about the trial

bFields = fieldnames(behaviour);

% get the names of the imaging related behaviours
behavNames = {};
c = 0;
for i = 1:length(bFields)
    
    if contains(bFields{i},'sensory') || contains(bFields{i}, 'imaging_')
        c = c +1;
        behavNames{c} = bFields{i};
    end
end


% if all the behaviours are not showing up, this is most likely the problem
for i = 1:length(behavNames)
    imaging = allign(behaviour, imaging, behavNames{i});
end


dates = fieldnames(imaging);

for i = 1:length(dates)
    
    date = dates{i};
    
    areas = fieldnames(imaging.(date));
    
    for ii = 1:length(areas)
        
        area = areas{ii};
        
        % get the names of the planes and the behavioural session
        % corresponding to those planes
        iFields = fieldnames(imaging.(date).(area));
        % get the names of just the planes
        planesIND = strfind(iFields,'plane');
        planes = iFields(find(not(cellfun('isempty', planesIND))));
        
        % get the name of just the behaviour
        behavName = iFields(find(cellfun('isempty', planesIND)));
        
        
        try
            behav = imaging.(date).(area).(behavName{1});
        catch
            warning('I cant find a behaviour to match one of the imaging sessions from %s', date)
            continue
        end
        
        % create a single list showing the outcome of trials
        % difficult to use the motor forward times as these generated
        % can occur up to 5 seconds before the trial result is printed
        
        % create a 2d cell with the trial type as a string and the
        % timings of the trial
        
        if isfield(behav, 'correct_trials')
            ct = dupMat(behav.correct_trials, 'correct');
            mt = dupMat(behav.missed_trials, 'missed');
            fp = dupMat(behav.falsepositive_trials, 'falsePositive');
            cr = dupMat(behav.correctrejection_trials,'correctRejection');
            it = dupMat(behav.initial_trials, 'initial');
            
            allTrials = horzcat(ct,mt,fp,cr,it);
            
            % sort all trials by their timings
            [~, idx] = sort(cell2mat(allTrials(1,:)));
            allTrials = allTrials(:,idx);
            
            % append the trial type information to the imaging behaviour
            % structure
            imaging.(date).(area).(behavName{1}).trialType = string(allTrials(2,:));
        end
        
       
        % the start of the trial (in frames) indicted by the start of the motor
        if isfield(behav, 'motor_atOrigin')
            tStart = behav.motor_atOrigin;
        else
            tStart = [];            
        end
        
        % the imaging is quite likely to end half way through a trial
        % at origin signals the end of a trial
        % so the length of this variable is the number of full trials
        numTrials = length(behav.motor_atOrigin) - 1;
        
        
        
        for iii = 1:length(planes)
            
            plane = planes{iii};
            
            % this variable will be the result of iterating
            % through each imaging behavioural session
            session = imaging.(date).(area).(plane);
            
            fluro = session.fluoresence_corrected;
            
            % get the length of the trial in frames
            fRate = session.fRate;
            
            
            % spikes are not extracted in some files
            if isfield(session, 'spike_timings')
                st = session.spike_timings;
                amps = session.spike_amps;
            else
                st = [];
                amps = [];
            end
            
                      
            %cells containing spike timings by each unit
            tBtSt = {};
            tBtAmps = {};
            tBtFlu = {};
            for t = 1:numTrials
                
                % the time of each trial start and end
                t0 = tStart(t);
                t1 = tStart(t+1);
             
                % loop to throw out trials that finish after the end of
                % imaging
                
                if t1 > length(fluro(1,:))
                    continue
                else
                    try
                        tBtFlu{t} = fluro(:,t0:t1);
                    catch
                        warning('probably got a proc file with no cells!!')
                        continue
                    end
                   
                    for unit = 1:length(st)
                        
                        % split the spike timings by trial 
                        u = st{unit};
                        a = amps{unit};
                        idx = find(u >= t0 & u <= t1);
                        tBtSt{unit,t} = u(idx) - t0;
                        
                        tBtAmps{unit, t} = a(idx);
                        
                    end
                end
            end
                       
            nUnits = size(tBtFlu{1},1);
                        
            comment = ['Dear Friedemann there are ' int2str(numTrials) ' trials, ' ...
                int2str(nUnits) ' units and a variable number of frames'];
            
            %append to the imaging structure
            imaging.(date).(area).(plane).trialByTrialFlu = tBtFlu;
            imaging.(date).(area).(plane).trialByTrialSpikes = tBtSt;
            imaging.(date).(area).(plane).trialByTrialAmps = tBtAmps;
            imaging.(date).(area).(plane).info = comment;
            
        end
    end
end
end

% function that takes an input of a 1d matrix
% and returns a cell of same length but with
% an extra dimension of tType
function m = dupMat(x, tType)

if isempty(x)
    m = [];
end

for matP = 1:length(x)
    m{1,matP} = x(matP);
    m{2,matP} = tType;
end


end


