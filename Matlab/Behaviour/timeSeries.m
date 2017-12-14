function imaging = timeSeries(imaging, behaviour)


% split the corrected flurosence by trial
% this will yield the flurosence from one second before the
% motor onset and three seconds after.
% hence this will not overlap with other trials
% in the passive stimulation case

% set the time before and after that the trial starts
tBefore = 1;
tAfter = 3;
disp(['using a trial length of ' num2str(tBefore + tAfter) ' seconds'])

bFields = fieldnames(behaviour);
% get the names of just the behaviours
bIND = strfind(bFields,'imaging_');
behavNames = bFields(find(not(cellfun('isempty', bIND))));

% if all the behaviours are not showing up, this is most likely the problem
for i = 1:length(behavNames)
    imaging = allign(behaviour, imaging, behavNames{i});
end


% if isfield(behaviour, 'imaging_discrimination')
%     imaging = allign(behaviour, imaging, 'imaging_discrimination');
% end
% 
% if isfield(behaviour, 'imaging_stimulation')
%     imaging = allign(behaviour, imaging, 'imaging_stimulation');
% end
% 
% if isfield(behaviour, 'imaging_detection')
%     imaging = allign(behaviour, imaging, 'imaging_detection');
% end

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
        tStart = behav.motor_start;
        
        
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
            
            tBtFlu = [];
            
            %cells containing spike timings by each unit
            tBtSt = {};
            tBtAmps = {};
            for t = 1:length(tStart)
                                
                % the time of each motor start
                motor = tStart(t);
                
                % the number of frames to count before and after
                % whisker stimulation
                frameBefore =  floor(tBefore * fRate);
                frameAfter = floor(tAfter * fRate);
                
                % loop to throw out trials that finish after the end of
                % imaging  
                
                if motor + frameAfter > length(fluro(1,:))
                    continue
                else
                    tBtFlu(t,:,:) = fluro(:,(motor - frameBefore):(motor + frameAfter));
                end
                           
             
                for unit = 1:length(st)
                    
                    % split the spike timings by trial (havent yet built
                    % in the 4 seconds thing from above
                    u = st{unit};
                    a = amps{unit};
                    idx = find(u >= tStart(t) & u <= tStart(t+1));
                    tBtSt{unit,t} = u(idx) - tStart(t);
                    
                    tBtAmps{unit, t} = a(idx);
                    
                end
            end
            
            nTrials = t;
            
            nUnits = size(tBtFlu,2);
            nFrames = size(tBtFlu,3);
            
            
            comment = ['Dear Friedemann there are ' int2str(nTrials) ' trials, ' ...
                int2str(nUnits) ' units and ' int2str(nFrames) ' frames'];
            
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


