% script to process multiple mice.
% there are two options for running this script.
% A directory (fPath) can be given -
% the directory given here should be the output of the
% workflow behav function and will contain folders 
% with the names of several mice. This function will process
% all data for mice with these names. 

% alternatively, a list of mouse names (mList) can be given.
% each of these mice will then be processed.

clear

%fPath = '/home/jamesrowland/Documents/ProcessedData/behaviour';
mList = {'CGCC5.4a', 'PVEM22.2h'};


if exist('fPath','var')
    toProcess = dir(fPath);
    
    % i = 3: ... is used because dir always seems to return a '.' and a '..'
    % this has the potential to cause a bug in the future
    for i = 3:length(toProcess)
        disp(['processing ' toProcess(i).name])
        pipeline(toProcess(i).name);
    end
else
    
    for i = 1:length(mList)
        disp(['processing ' mList{i}])
        pipeline(mList{i});
    end
end

