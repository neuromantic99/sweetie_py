function corrected = correctTooSoon(correct, missed, correct_rejection, false_positive, too_soon)

trial_comb = [correct,missed, correct_rejection,false_positive];

t_window = 3000;

%if any too_soons occur within the time_window to another trial outcome,
%remove it
corrected = too_soon;

for i = 1:length(too_soon)
    ts = too_soon(i);
    
    for ii = 1:length(trial_comb)
        tc = trial_comb(ii);     
    
        if abs(ts-tc) < t_window          
            corrected(i) = [];           
        end
    end
end



