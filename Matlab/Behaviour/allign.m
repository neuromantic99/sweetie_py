function imaging = allign(behaviour, imaging, behavType)

% takes the input of the behaviour, imaging structures
% and behavType. Bins the behaioural data based on the imaging
% frame rate etc
%
% Also moves the imaging behaviour into the imaging structure
%
% pretty dirty function, may cause bugs at later date
% need to change this for the speed as it is
% already binned

behav = behaviour.(behavType);

bFields = fieldnames(behav);

% loop through each date of behaviour
for i = 1:length(bFields)
    
    date = bFields{i};
    
    try
        areas = fieldnames(imaging.(date));
    catch
        warning('Cannot find both the imaging and the behaviour from date  %s', date)
        continue
    end
    
    % loop through each area of the behaviour at each date
    for ii = 1:length(areas)
        
        % this variable will be the result of iterating
        % through each imaging behavioural session
        area = areas{ii};
        try
            session = behav.(date).(area);
        catch
            keyboard
            error('an error here most likely means the subject ID or the area of a file is incorrect')
        end
        
        sFields = fieldnames(session);
        
%         preT = session.velocityTime<0;
%         session.velocityTime(preT) = [];
%         session.velocity(preT) = [];
        
        
        
        % get the imaging session relevant to the behaviour
        iFields = fieldnames(imaging.(date).(areas{ii}));
        imSession = imaging.(date).(areas{ii}).(iFields{1});
        
        % get the frame rate of the imaging on each date in
        % each area
        
        fRate = imSession.fRate;
        
        % get the length of the imaging in seconds
        maxFrame = length(imSession.fluoresence_corrected);
        lenIm = maxFrame / fRate;
        
        % each field of each behaviour at each date
        for iii = 1:numel(sFields)
            
            % iterate through each field in the session
            f = session.(sFields{iii});
            
            if isinteger(f) && ~strcmp(sFields{iii}, 'velocity')
                
                % cannot do float divisions with int64
                f = double(f);
                
                fSecs = f/1000; %convert from ms to s
                
                %remove behavioural data that occured
                %after imaging stopped
                highIND = find(fSecs>lenIm);
                fSecs(highIND) = [];
                
                %bin the behavioural data by frame
                edges  = linspace(0,lenIm,lenIm*fRate);
                fBin = discretize(fSecs, edges);
                
                % change the session field to reflect fBin
                session.(sFields{iii}) = fBin;
            else
                session.(sFields{iii}) = f;
            end
            
        end
        
        % ditch the NaNs from the running speed - corresponding to speed
        % recorded before the start of imaging    
        vel = session.velocity;
        vel_time = session.velocityTime;
        
        pre_time = isnan(vel_time);
        
        vel_time(pre_time) = [];
        vel(pre_time) = [];
        
        %also remove the veloicites from the end of imaging
        vel =  vel(1:length(vel_time));
        
        velBinned = cell(max(vel_time),1);
        
        
        
        % bin the velocities by frame and take a mean. Giving the 
        % avergae speed (steps / second) of the mouse across the frame
        
        for samp = 1:length(vel)
            % the frame index it belongs to
            fIND = vel_time(samp);
            
            velBinned{fIND} = [velBinned{fIND} vel(samp)];
        end
            
        for bin = 1:length(velBinned)
            
            velBinned{bin} = mean(velBinned{bin});
        end
        
        velBinned = cell2mat(velBinned);
        
        session.velocity = velBinned;
        session = rmfield(session,'velocityTime');

        %trim the motor behaviour so it only reflects full trials
        numTrials = length(session.motor_atOrigin) - 1;
        session.motor_start = session.motor_start(1:numTrials);
        session.motor_atWhisk = session.motor_atWhisk(1:numTrials);
        session.motor_back = session.motor_back(1:numTrials);
        session.stim_position = session.stim_position(1:numTrials,:);
        session.stim_speed = session.stim_speed(1:numTrials,:);
        
        
        
        
        
        
        
        
        
        %append to the imaging structure
        imaging.(date).(areas{ii}).session_behaviour = session;
        
    end
    
    
    
end

end


