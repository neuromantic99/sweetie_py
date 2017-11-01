
clear all;
close all;
clc;

load('./chmap.mat');
%% Load Openephys files to Matlab
% for continuous data from Oxford
% filehead, channel number + 16, filefoot
outputpath = ['./170704/'];
dataname = 'PV2_NoStim';
filepath =  ['./',dataname,'/'];      % files location
filehead = '108';                     % file name head
Fs = 30000;
nCh = 32;                                           % number of channel

testdata = load_open_ephys_data([filepath, filehead, '_CH', num2str(1), '.continuous']);
lengthData = length(testdata);
ts = [0:(lengthData-1)].*(1/Fs);

stream = zeros([nCh, lengthData]);
for idxCh = 1:nCh   
    stream(map.NN(idxCh), :) = load_open_ephys_data([filepath, filehead, '_CH', num2str(map.openephys(idxCh)), '.continuous']);
end

disp('Loading is finished');


%% Matlab to Klusta (binary file)

% Export data
% Binary raw data file(s) (FileBase.dat) and binary LFP signal (FileBase.eeg) the binary
% file format is as follows: each sample is stored as type short integer (2 bytes) in the
% order Channel_1:Sample_1, Channel_2:Sample_1, ..., Channel_N:Sample_1,
% Channel_1:Sample_2, Channel_2:Sample_2, ... etc. The number of channels is not
% always a multiple of 8 (eight recording sites per shank) because bad channels (due to
% very high impedance or broken shank) were removed from the data.
output_stream = stream_car;

voltage_gain = 1e3; % since Klusta accepts only 16-bit integer format, float data will be lost. To solve this problem, voltage gain was multiplied to data
voltage_gain = floor(32767 / (max(max(abs(output_stream)))));

RemapData = zeros([lengthData*nCh,1]);             % new file format
idxPoint = 0;
for idxDataPoint = 1:lengthData                    % re-arrange data points
    for idxCh = 1:nCh
        idxPoint = idxPoint +1;
        RemapData(idxPoint) = output_stream(idxCh,idxDataPoint).*voltage_gain;    
    end
end


expname = sprintf('%s_vg%d',dataname,voltage_gain);             % data export
fp = fopen([outputpath, expname, '.dat'],'w');        % file open for write
fwrite(fp, RemapData, 'int16');                     % export data file
fclose(fp);                                         % file close


