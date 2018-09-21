function trial_type = concatTrials(session)

% takes an argugment of session, a structure containing any of the fields:
% correct, missed, correct_rejection, false_positive or too_soon
% returns an ordered list of trial type

% unsorted cells of trial outcomes
correct_str = cellstr(repmat('correct', [length(session.correct),1]));
missed_str = cellstr(repmat('missed', [length(session.missed),1]));
cr_str = cellstr(repmat('correct_rejection', [length(session.correct_rejection),1]));
fp_str = cellstr(repmat('false_positive', [length(session.false_positive), 1]));
ts_str = cellstr(repmat('too_soon', [length(session.too_soon), 1]));

% concatenate unsorted trial outcome string cells
trial_strs = [correct_str; missed_str; cr_str; fp_str; ts_str];

% remove empty cells
trial_strs = trial_strs(~cellfun('isempty',trial_strs));  

% concaenate all the trial times
trial_times = [session.correct, session.missed, session.correct_rejection, ...
    session.false_positive, session.too_soon];

% get the index of the sorted trial times which indicates the order the
% trials occured in
[~, trial_idx] = sort(trial_times);

% sort the trial outcome strings by their times
trial_type = trial_strs(trial_idx);
