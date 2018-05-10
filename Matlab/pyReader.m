function session = pyReader(fPath) 

fid = fopen(fPath);
tline = fgetl(fid);

lines = {};

while ischar(tline)
    lines{end+1} = tline;
    tline = fgetl(fid); 
end
    
session = getMetaData(lines);
session.times = getTimes(lines);
session.print_lines = getPrintLines(lines);


