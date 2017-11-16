function imaging = shiftBehaviour(imaging, behaviour)
% takes the input of the behaviour and imaging structures 
% and moves the imaging behaviour into the imaging structure


if isfield(behaviour, 'imaging_discrimination')
    discrim = behaviour.imaging_discrimination;
else
    discrim = [];
end

if isfield(behaviour, 'imaging_stimulation')
    stim = behaviour.imaging_stimulation;
else
    stim = [];
end

for i = 1:length(discrim)
    date = char(fieldnames(discrim(i)));
    area = char(fieldnames(discrim(i).(date)));
 %   area = discrim.(date).area;
  %  area = erase(area,'0');
    imaging.(date).(area).discrimination = behaviour.imaging_discrimination(i).(date);
end

for i = 1:length(stim)
    
    date = char(fieldnames(stim(i)));
    areas = fieldnames(stim(i).(date));
    
    for ii = 1:length(areas)        
     
        %area = erase(area,'0');

        imaging.(date).(areas{i}).stimulation = stim(i).(date).(areas{i});
    end
end

end




