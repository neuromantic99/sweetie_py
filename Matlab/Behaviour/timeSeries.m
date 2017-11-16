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
        tStart = tStart - 15;
        
        for iii = 1:length(planes)
            
            plane = planes{iii};
            
            % this variable will be the result of iterating
            % through each imaging behavioural session
            session = imaging.(date).(area).(plane);  
            
            fluro = session.fluoresence_corrected;
           
            % cell containing trial by trial information
            tBt = {};
            for t = 1:length(tStart)-1
                
                % split the corrected flurosence by trial
                tBt{t} = fluro(:,tStart(t):tStart(t+1));
                
         
            end
            
           %append to the imaging structure
           imaging.(date).(area).(plane).trialByTrial = tBt;
                 
         
                 
                 
        end
    end
                 
                
        
        
    end
    
end





