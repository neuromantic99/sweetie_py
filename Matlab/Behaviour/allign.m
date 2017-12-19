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
            
            if ismember(sFields{iii}, {'motor_start','licks','water_delivered', 'running_forward', 'correct_trials','missed_trials','falsepositive_trials','correctrejection_trials','initial_trials', 'flavourA','flavourB'})
               
                
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
        
        % remove tStart because it is not necessary
        if isfield(session, 'tStart')
            session = rmfield(session,'tStart');
        end
        
        %append to the imaging structure
        imaging.(date).(areas{ii}).session_behaviour = session;
        
    end
    

    
end

end


