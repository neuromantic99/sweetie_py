function too_soon = correctTooSoon(correct, missed, correct_rejection, false_positive, too_soon)

%if any too_soons occur within the time_window to another trial outcome,
%remove it
trial_comb = [correct,missed, correct_rejection,false_positive];

%time window encompassing trial (ms)
t_window = 3000;

 % index of too soons to delete 
del_ind = [];

for i = 1:length(too_soon)
    ts = too_soon(i);
    
    for ii = 1:length(trial_comb)
        tc = trial_comb(ii);
        
        if abs(ts-tc) < t_window           
            del_ind(end+1) = i;
        end
    end
end

too_soon(del_ind) = [];



