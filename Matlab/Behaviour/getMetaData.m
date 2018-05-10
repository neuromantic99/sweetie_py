function meta_struct = getMetaData(lines)

for i = 1:length(lines)
    
    l = lines{i};
    
        if contains(l, 'Experiment name')
            sp = strsplit(l, ': ');
            meta_struct.experiment_name = sp{2};
        end
      
        if contains(l, 'Task name')
            sp = strsplit(l, ': ');
            meta_struct.task_name = sp{2};
        end
        
        if contains(l, 'Subject ID')
            sp = strsplit(l, ': ');
            meta_struct.subject_ID = sp{2};
        end
        
        if contains(l, 'Start date')
            sp = strsplit(l, ': ');
            meta_struct.date = sp{2};
        end

end

