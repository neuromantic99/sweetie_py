fid = fopen('/Users/James/Desktop/Raw_recordings/2017-07-06_18-27-01/108_CH23.continuous');
hdr = fread(fid, 1024, 'char*1');
eval(char(hdr'));
info.header = header;

