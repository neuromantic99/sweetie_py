% script to process all the mice in a given directory
% the directory given here in fPath contains folders 
% with the names of several mice. This function will process
% all data for mice with these names. 

fPath = '/home/jamesrowland/Documents/ProcessedData/behaviour';
toProcess = dir(fPath);

% i = 3: ... is used because dir always seems to return a '.' and a '..'
% this has the potential to cause a bug in the future

for i = 3:length(toProcess)
    pipeline(toProcess(i).name);
end

