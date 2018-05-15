function outSession = bMerger(inSession)

fs = fieldnames(inSession);


TTLs = inSession.TTLs;

%create the output structure that will be mutated after TTL slicing.
outSession = inSession;

%index of trials that occured within the imaging.
tIND = [];

% index of required velocities
velIND = [];

for i = 1:length(fs)
    %iterate through each beahvioural variables
    f = inSession.(fs{i});
    

    if ~strcmp(fs{i}, 'TTLs') && ~strcmp(fs{i}, 'velocity')  && isa(f, 'double')
        
        %list to append the values between TTLs
        imB = [];
              
        for s = 1:length(TTLs(1,:))
        
            % the index of the values in the list between 2 TTLs
            IND = find(f>=TTLs(1,s) & f<=TTLs(2,s));
            
            % create the array which will have TTL times subtracted
            subbed = f(IND);

            % get the indexes of velocity time to index velocity
            if strcmp(fs{i}, 'velocityTime')
                velIND = [velIND IND];
            end
            
            % this loops works on the second imaging session onwards.
            % it adds the time of the end of each previous imaging session
            % then subtracts the start time of each previous imaging
            % session and the current imaging session. Effectively 
            % removing all the timings from the behaviour that were not 
            % imaged.          
            if s > 1          
                for c = 1:s-1                    
                    subbed = subbed + TTLs(2, c);
                    subbed = subbed - TTLs(1, c+1);
                end
            end
                
            % subtract the first TTL time from all values
            subbed = subbed - TTLs(1,1);
            
            % stick all subtracted values together into a single array
            imB = [imB subbed];
            
            %also need to get the index of trials which were recorded
            %get this from the timing of motor movement (motor_start??)
            if strcmp(fs{i}, 'motor_start')
                tIND = [tIND IND];
            end
            
        end
        
        outSession.(fs{i}) = imB;
        
        
    end
end

if isfield(inSession, 'stim_position')
    outSession.stim_position = inSession.stim_position(tIND);
    outSession.stim_speed = inSession.stim_speed(tIND);
end
    
outSession.velocity = inSession.velocity(velIND);

















