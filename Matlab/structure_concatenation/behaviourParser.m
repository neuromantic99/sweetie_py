function behavStruct = behaviourParser(allSessions)

behavStruct = {};

for i = 1:length(allSessions)
    
    session = allSessions{i};
    
    task = session.task;
    
    date = session.date;
    
    % split the running matrix to seperate fields 
    % keep these fields in the original structure so can append to new structure in bulk
    session.velocity = transpose(session.running(:,2));
    session.velocityTime = transpose(session.running(:,1));
    session = rmfield(session,'running');
    
    
    %make the date into a valid structure field name
    date = strrep(date,'-','_');
    date = strcat('date_', date);
  
    
    % add fields from the raw data structure to the new structure
    fields = fieldnames(session);
    for ii = 1:length(fields)
        behavStruct.(task).(date).(fields{ii}) = session.(fields{ii});
    end
    
    % get the area number and take out '0' so it matches with imaging
    
    if length(session.area) ~= 0
        area = session.area;
        area = erase(area,'0');
        
        % filthy way of adding the area field to imaging behaviour only
        tempStruct.(date).(area) = behavStruct.(task).(date);
        behavStruct.(task) = tempStruct;
    end
    
end



end


