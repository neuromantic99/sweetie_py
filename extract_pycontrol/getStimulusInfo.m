function [stim_position, stim_speed] = getStimulusInfo(session)

% function to the the stimulus position and speed in the sensory
% stimulation task

pl = session.print_lines;

stim_position = {};
stim_speed = {};


for i = 1:length(pl)
    
    line = pl{i};
    lineSplit = split(line, ' ');
    
    if contains(line, 'whisker stim position is')
        stim_position{end+1} = lineSplit{7};
    elseif contains(line, 'speed is')
        stim_speed{end+1} = lineSplit{5};
    end
end
        
    
