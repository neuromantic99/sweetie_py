function pt_list = printListTimes(pl, str)

%searches through the list of printed lines and returns the times of lines
%containing str.

pt_list = [];

for i = 1:length(pl)
    
    if contains(pl(i), str)
        ss = split(pl(i),' ');
        pt_list(end+1) = str2double(ss{2});
    end
    
end
