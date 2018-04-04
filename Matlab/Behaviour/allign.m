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
        %areas = fieldnames(imaging.(date));
        areas = fieldnames(behav.(date));
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
        
        % this performs TTL subtraction and removes data from outside
        % imaging.
        session = bMerger(session);
            
        
        sFields = fieldnames(session);
        
        
        % get the imaging session relevant to the behaviour
        try
            
            iFields = fieldnames(imaging.(date).(areas{ii}));
        catch
            error('likely cannot find imaging to match behaviour')
        end
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
            
            % im not entirely sure whether this is robust and whether
            % future variables will be saved as integer or double, so
            % please check the start of this loop.
            
            if isinteger(f) && ~strcmp(sFields{iii}, 'velocity')
                
                % cannot do float divisions with int64
                f = double(f);

                fSecs = f/1000; %convert from ms to s
                
                %bin the behavioural data by frame
                edges  = linspace(0,lenIm,lenIm*fRate + 1);
                fBin = discretize(fSecs, edges);
                
                % change the session field to reflect fBin
                session.(sFields{iii}) = fBin;
            else
                session.(sFields{iii}) = f;
            end
            
        end

       
        % bin the velocities by frame and take a mean. Giving the 
        % avergae speed (steps / second) of the mouse across the frame
        
        vel = session.velocity;
        vel_time = session.velocityTime;
        
        velBinned = cell(max(vel_time),1);
        
        for samp = 1:length(vel)
            % the frame index it belongs to
            fIND = vel_time(samp);
            try
                velBinned{fIND} = [velBinned{fIND} vel(samp)];
            catch
                keyboard
            end
        end
            
        for bin = 1:length(velBinned)
            
            velBinned{bin} = mean(velBinned{bin});
        end
        
        velBinned = cell2mat(velBinned);
        
        session.velocity = velBinned;
        session = rmfield(session,'velocityTime');
        
        
        if isfield(session, 'stim_position')
        
            % python workflow doens't like these character arrays
            sp = session.stim_position;
            for iiiii = 1:length(sp)
                sps(iiiii) = str2double(sp(iiiii,:));
            end

            ss = session.stim_speed;
            for iiiii = 1:length(ss)
                sss(iiiii) = str2double(ss(iiiii,:));
            end


            %append to the imaging structure
            session.stim_speed = sss;
            session.stim_position = sps;
        end
        
        imaging.(date).(areas{ii}).session_behaviour = session;

        
    end
    
    
    
end

end


