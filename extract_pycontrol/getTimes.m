function times_struct = getTimes(lines)

times_struct = {};

% get a cell containing all the events and their corresponding numbers
for i = 1:length(lines)
    l = lines{i};
    if ~isempty(l)
        if  strcmp(l(1), 'E')
            events_info = strsplit(l(4:end-1), ',');
            
        elseif  strcmp(l(1), 'S')
            states_info = strsplit(l(4:end-1), ',');
        end
    end
end

% combine info about states and events
times_info = [events_info, states_info];

%loop through each event found
for ti = times_info
    
    % a list of the times a state or event occured
    times_list = [];
   
    % get the names of each event and format them as valid fieldnames
    % removing spaces and quote marks
    tisp = strsplit(ti{:}, ':');
    t = strrep(tisp{1}, '''', '');
    times_name = strrep(t, ' ', '');
    
    % get the number of the event in the txt file. Removing white space
    times_num = strrep(tisp{2}, ' ', '');
    
    % loop through each line to look for event times for each evetn
    for i = 1:length(lines)
        l = lines{i};
        
        % the first logical here is for speed, incorrect events will often
        % break through this, but filters so not all lines need to be split
        if ~isempty(l) && strcmp(l(end), times_num(end)) && strcmp(l(1), 'D') 
            
            % split the event lines. ind 3 is the event number, ind 2 is the
            % time
            l_split = strsplit(l,' ');
            if strcmp(times_num, l_split{3})  
                times_list(end+1) = str2double(l_split{2});
            end
            
        end
    end
    
    %append list of times to the overall structure
    times_struct.(times_name) = times_list;
    
end
