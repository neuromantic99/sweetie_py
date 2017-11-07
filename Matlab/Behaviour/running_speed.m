function [speed, mid_time_bin] = running_speed(behavioural_data)

% function to parse the running speed of the mouse based on the time
% bins at which the mouse is recorded as moving forwards

% mariangela 2017
% edit JR 2017

while 1

running_forward = behavioural_data.running_forward;

if isempty(running_forward)
    speed = 0;
    mid_time_bin = 0;
    break
end 

running_forward = reshape(running_forward,1, numel(running_forward));

running_forward = running_forward/1000; %turn data from ms to s

try
end_of_session = ceil(running_forward(end)); %duration of session in s
catch
    keyboard
end
     
time_bins= 10; %duration of time bins in s
radius_wheel=12; %radius of the wheel in cm

L=(1:time_bins:(end_of_session-time_bins)); %start of the time bin
U=((1+time_bins):time_bins:end_of_session); %end of time bin
mid_time_bin=(L+U)/2;

forwards_count=[]; %number of 3.6 degres steps for each time bin

for ii= 1: length(L)
    count_timings= running_forward(running_forward>=L(ii) & running_forward<U(ii)); %list occurrances in each time bin
    total_count= length(count_timings); %number of occurrances for each time bin
    forwards_count = [forwards_count; total_count];%total list of how many 'going_forward' events happened in every time bin (i.e. every 10sec)
end

angular_speed_deg=(forwards_count*3.6)/time_bins; % speed is calculated here as degrees every sec
angular_speed_rad=angular_speed_deg*(2*pi)/360; %radians per second
speed=angular_speed_rad*radius_wheel; %speed (cm/s)

break

end
end




