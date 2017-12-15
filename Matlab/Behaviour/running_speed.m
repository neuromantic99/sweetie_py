function [binCounts,mid_time_bin] = running_speed(behavioural_data)

% function to parse the running speed of the mouse based on the time
% bins at which the mouse is recorded as moving forwards

% edit JR 2017

while 1
    
time_bins= 7; %duration of time bins in s

try
    running_forward = behavioural_data.running_forward;
catch
    binCounts = 0;
    mid_time_bin = 0;
    break
end

% the length of the behavioural session in seconds
lenSession = ceil(behavioural_data.session_length / 1000);

if isempty(running_forward) || lenSession == 0
    binCounts = 0;
    mid_time_bin = 0;
    break
end 

% the times in seconds at which running was reported
running_forward = running_forward/1000; 
    


binEdges = 0:time_bins:lenSession;

histy = histogram(running_forward,binEdges);


binCounts = histy.BinCounts;

for i = 1:length(binEdges) -1
    mid_time_bin(i) = (binEdges(i) + binEdges(i+1)) / 2;
end

break

end
end




