function imaging = timeSeries(imaging, behaviour)

if isfield(behaviour, 'imaging_discrimination')
    imaging = allign(behaviour, imaging, 'imaging_discrimination');
end

if isfield(behaviour, 'imaging_stimulation')
    imaging = allign(behaviour, imaging, 'imaging_stimulation');
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
        
        behav = imaging.(date).(area).(behavName{1});
        
        % the start of the trial (in frames) indicted by the start of the motor
        tStart = behav.motor_start;
        %tStart = tStart - 15;
        
        for iii = 1:length(planes)
            
            plane = planes{iii};
            
            % this variable will be the result of iterating
            % through each imaging behavioural session
            session = imaging.(date).(area).(plane);
            
            fluro = session.fluoresence_corrected;
            st = session.spike_timings;
            amps = session.spike_amps;
            
            
            % cell containing trial by trial information
            tBtFlu = {};
            
            %2d cell containing spike timings by each unit
            tBtSt = {};
            tBtAmps = {};
            for t = 1:length(tStart)-1
                
                % split the corrected flurosence by trial
                tBtFlu{t} = fluro(:,tStart(t):tStart(t+1));
                
                for unit = 1:length(st)
                    
                    % split the spike timings by trial
                    u = st{unit};
                    a = amps{unit};
                    idx = find(u >= tStart(t) & u <= tStart(t+1));                    
                    tBtSt{unit,t} = u(idx) - tStart(t);
                    
                    tBtAmps{unit, t} = a(idx);
                    
                end
            end
            
            nTrials = t;
            nUnits = size(tBtFlu{1},1);
            nFrames = size(tBtFlu{1},2);
            
         
            comment = ['Dear Friedemann there are ' int2str(nTrials) ' trials, ' ...
                int2str(nUnits) ' units and ' int2str(nFrames) 'ish frames'];  
             
            %append to the imaging structure
            imaging.(date).(area).(plane).trialByTrialFlu = tBtFlu;
            imaging.(date).(area).(plane).trialByTrialSpikes = tBtSt;
            imaging.(date).(area).(plane).trialByTrialAmps = tBtAmps;
            imaging.(date).(area).(plane).info = comment;
            
            

            
            
            
            
        end
    end
    
    
    
    
end

end





