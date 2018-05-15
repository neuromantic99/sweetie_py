function session = pyReader(fPath) 

fid = fopen(fPath);
tline = fgetl(fid);

lines = {};

while ischar(tline)
    lines{end+1} = tline;
    tline = fgetl(fid); 
end

% check it is actually a pycontrol txt file
check = split(lines{1}, ' ');

if ~strcmp(check{1}, 'I')
    session = [];
    return
end
    
session = getMetaData(lines);
session.times = getTimes(lines);
session.print_lines = getPrintLines(lines);


