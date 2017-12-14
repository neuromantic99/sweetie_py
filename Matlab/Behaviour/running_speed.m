function [binCounts,mid_time_bin] = running_speed(behavioural_data)

% function to parse the running speed of the mouse based on the time
% bins at which the mouse is recorded as moving forwards

% mariangela 2017
% edit JR 2017

while 1

try
    running_forward = behavioural_data.running_forward;
catch
    binCounts = 0;
    binEdges = 0;
    break
end

if isempty(running_forward)
    binCounts = 0;
    binEdges = 0;
    break
end 

% the times in seconds at which running was reported
running_forward = running_forward/1000; 

% the length of the behavioural session in seconds
lenSession = ceil(behavioural_data.session_length / 1000);

     
time_bins= 7; %duration of time bins in s
radius_wheel=12; %radius of the wheel in cm

binEdges = 0:time_bins:lenSession;

histy = histogram(running_forward,binEdges);
binCounts = histy.BinCounts;

for i = 1:length(binEdges) -1
    mid_time_bin(i) = (binEdges(i) + binEdges(i+1)) / 2;
end



% 
% 
% angular_speed_deg=(forwards_count*3.6)/time_bins; % speed is calculated here as degrees every sec
% angular_speed_rad=angular_speed_deg*(2*pi)/360; %radians per second
% speed = double(angular_speed_rad*radius_wheel); %speed (cm/s)
break

end
end




