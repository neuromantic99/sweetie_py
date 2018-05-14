function print_lines = getPrintLines(lines)

print_lines = {};

for i = 1:length(lines)
    
    l = lines{i};
    
    if ~isempty(l) && strcmp(l(1), 'P')
        print_lines{end+1} = l;
    end
    
end

end

