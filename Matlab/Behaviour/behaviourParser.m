function allSessions = behaviourParser(fPath, mouse)

fPath= [fPath mouse];

% find all the mat files in subfolders for a given mouse
allMats=dir([fPath '/' '**/*.mat']);

%how many times has been delivered water in every session
tot_water_deliveries=[];

%water deliveries amount per session normalized for the max over sessions
proportion_over_sessions=[];

allSessions = {};

for i = 1:length(allMats)

    session = allMats(i);
   
    % load the raw data and save it to the structure
    f = load([session.folder '/' session.name]);
    raw = f.behavioural_data;
    
    sessionType = raw.sessionType;
      
    date = raw.date;

    %make the date into a valid structure field name
    date = strrep(date,'-','_');
    date = strcat('date_', date);
      
    % get the area number and take out '0' so it matches with imaging
    if isfield(raw, 'area')
        area = raw.area;
        area = erase(area,'0');
    else
        area = 'area_not_found';      
    end
        
    % add fields from the raw data structure to the new structure
    fields = fieldnames(raw);
    for ii = 1:length(fields)
        allSessions.(sessionType).(date).(fields{ii}) = raw.(fields{ii});
    end
    
    % parse the raw data to the running speed algorithm
    [speed, mid_time_bin] = running_speed(raw);
    
    % save running data in the allSessions structure
    allSessions.(sessionType).(date).speed = speed;
    allSessions.(sessionType).(date).mid_time_bin = mid_time_bin';

    try
        water_delivered = raw.water_delivered;
        water_delivered = water_delivered/1000; % convert to ms
    catch
        disp(['no water delivered field for ' mouse ' ' session.name]) 
    end
    
    try
        licks = raw.licks;
        licks=licks/1000; %convert to ms
    catch
        disp(['no lick field for ' mouse ' ' session.name]) 
    end
    
    % the total number of water deliverys across sessions
    tot_water_deliveries=[tot_water_deliveries length(water_delivered)];
    
    allSessions.(sessionType).(date).licks = licks;
    allSessions.(sessionType).(date).water_delivered = water_delivered;

end

max_water=max(tot_water_deliveries);

for i=1:length(tot_water_deliveries)
    proportion_over_sessions=[proportion_over_sessions (tot_water_deliveries(i)*100/max_water)];
end

allSessions.max_water = max_water;
allSessions.proportion_over_sessions = proportion_over_sessions;

end
















