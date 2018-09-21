function [correct, missed, correct_rejection, false_positive, too_soon] = getTrialType(inSession)

pl = inSession.print_lines;

correct = printListTimes(pl, 'correct trial');
missed = printListTimes(pl, 'missed trial');
correct_rejection = printListTimes(pl, 'correct rejection');
false_positive =  printListTimes(pl, 'false positive');
too_soon = printListTimes(pl, 'tooSoon');

%sometimes too soon is printed at the same time as another
%trial outcome this should be corrected for by popping these values out
%of too_soon
too_soon = correctTooSoon(correct,missed, correct_rejection, ...
            false_positive, too_soon);
 
% debounce any trial ouotcome indications that occur within 3 seconds 
deb_time = 3000;

correct = debounce(correct, deb_time);
missed = debounce(missed, deb_time);
correct_rejection = debounce(correct_rejection, deb_time);
false_positive = debounce(false_positive, deb_time);
too_soon = debounce(too_soon, deb_time);