function trialType = getTrialType(inSession)

trialType = {};
pl = inSession.print_lines;

for i = 1:length(pl)
    if contains(pl(i), 'correct trial')
        trialType{end+1} = 'correct';
    elseif contains(pl(i), 'missed trial')
        trialType{end+1} = 'missed';
    elseif contains(pl(i), 'correct rejection')
        trialType{end+1} = 'correct_rejection';
    elseif contains(pl(i), 'false positive')
        trialType{end+1} = 'false_positive';
    end
end
