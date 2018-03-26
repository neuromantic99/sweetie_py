function behaviour = merger(behaviour)

% function to merge behavaiours from the same area that have been merged to
% the same suite2p file
% currently only supports one double imaging per animal 

% super super beta, probably the dirtiest code i've ever written. will cause bugs
behaviour = rmfield(behaviour, 'merge');


% iterate through the behavioural structure to find merge behaviours
tasks = fieldnames(behaviour);

for i = 1:length(tasks)
    
    task = tasks{i};
    dates = fieldnames(behaviour.(task));
    
    if contains(task,'sensory') || contains(task, 'imaging_')
        
        for ii = 1:length(dates)
            
            date = dates{ii};
            areas = fieldnames(behaviour.(task).(date));
            
            for iii = 1:length(areas)
                
                area = areas{iii};
                
                datey = date;
                
                if strcmp(area(end), 'a')
                    
                    bA = behaviour.(task).(date).(area);
                    
                elseif strcmp(area(end), 'b')
                    
                    bB = behaviour.(task).(date).(area);
                end
                
            
                
            end
        end
    end
end

% add the endTTL time of A to B
fieldsB = fieldnames(bB);

for i = 1:length(fieldsB)
    field = fieldsB{i};
    
    if isinteger(bB.(field)) && ~strcmp(bB.(field), 'velocity')
        
        intB = bB.(field);
        
        intB(intB<0) = [];
        
        bB.(field) = intB + int64(bA.endTTL);
        
    end
end


% snip the end of the behaviour off behaviour A
fieldsA = fieldnames(bA);

for i = 1:length(fieldsA)
    field = fieldsA{i};
    
    if isinteger(bA.(field)) && ~strcmp(field, 'velocity') && ~strcmp(field, 'endTTL')
        
        int = bA.(field);
        int(int>bA.endTTL) = [];
        int(int<0) = [];
        
        intB = bB.(field);
        
        intCOM = horzcat(int, intB);
        
        bA.(field) = intCOM;
        
    end
    
    if ismember(field, {'stim_position', 'stim_speed'}) || strcmp(field, 'velocity')
        
        charA = bA.(field);
        charB = bB.(field);
                
        % this is a shortcut for now
        % bugs may arise at this point
        try
            charCOM = [charA; charB];
        catch
            charCOM = [charA, charB];
        end
        
        bA.(field) = charCOM;
        
    end
    
end

% remove the seperated areas and add the new behaviour

tasky = bA.task;

oldA = bA.area;
oldB = bB.area;

newArea = bA.area(1:6);

newArea = erase(newArea,'0');
oldA = erase(oldA,'0');
oldB = erase(oldB, '0');


behaviour.(tasky).(datey).(newArea) = bA;
behaviour.(tasky).(datey) = rmfield(behaviour.(tasky).(datey), {oldA, oldB});


    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
