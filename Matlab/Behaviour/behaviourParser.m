function allSessions = behaviourParser(fPath, mouse)

fPath= [fPath mouse];

% find all the mat files in subfolders for a given mouse
allMats=dir([fPath '/' '**/*.mat']);

allSessions = {};

for i = 1:length(allMats)
    
    session = allMats(i);
    
    % load the raw data and save it to the structure
    f = load([fPath '/' session.name]);
    raw = f.behavioural_data;
    
    task = raw.task;
    
    date = raw.date;
    
    %make the date into a valid structure field name
    date = strrep(date,'-','_');
    date = strcat('date_', date);
    
    % add fields from the raw data structure to the new structure
    fields = fieldnames(raw);
    for ii = 1:length(fields)
        allSessions.(task).(date).(fields{ii}) = raw.(fields{ii});
    end
    
    
    % get the area number and take out '0' so it matches with imaging
    
    if length(raw.area) ~= 0
        area = raw.area;
        area = erase(area,'0');
        
        % filthy way of adding the area field to imaging behaviour only
        tempStruct.(date).(area) = allSessions.(task).(date);
        allSessions.(task) = tempStruct;
    end
    
end



end


