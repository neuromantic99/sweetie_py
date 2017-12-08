function imaging = allign(behaviour, imaging, behavType)

% takes the input of the behaviour, imaging structures  
% and behavType (currently 'imaging_discrimination' or
% 'imaging_stimulation'. Bins the behaioural data based on the imaging
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
            error('an error here most likely means the subject ID on a file is incorrect')
        end
        
        sFields = fieldnames(session);
      
        % get the imaging session relevant to the behaviour
        iFields = fieldnames(imaging.(date).(areas{ii}));
        imSession = imaging.(date).(areas{ii}).(iFields{1});

        % get the frame rate of the imaging on each date in
        % each area   
        
        fRate = imSession.fRate / 2;
        %fRate = 15.03;

        % get the length of the imaging in seconds
        maxFrame = length(imSession.fluoresence_corrected);
        lenIm = maxFrame / fRate;
       
        % each field of each behaviour at each date
        for iii = 1:numel(sFields)

            % iterate through each field in the session
            f = session.(sFields{iii});

            if isa(f,'double')
                
                if strcmp(sFields{iii}, 'speed')
                    continue
                end
                
                % mid_time_bin is already in seconds
                if ~strcmp(sFields{iii}, 'mid_time_bin') 
                    fSecs = f/1000; %convert from ms to s
                else
                    fSecs = f;
                end
                    

                %remove behavioural data that occured 
                %after imaging stopped
                highIND = find(fSecs>lenIm);
                fSecs(highIND) = [];

                %bin the behavioural data by frame
                edges  = linspace(0,lenIm,lenIm*fRate);
                fBin = discretize(fSecs, edges);
                
                % change the session field to reflect fBin
                session.(sFields{iii}) = fBin;
                
            end
        end
        
    %append to the imaging structure
    imaging.(date).(areas{ii}).stimulation = session;
    
    end
    
    
end

end
