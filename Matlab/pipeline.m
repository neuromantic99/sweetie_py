function [imaging, behaviour] = pipeline(mouse)

% Pipeline to generate the structure containing all the information
% (behaviour and imaging about a mouse.

% Requires the functions: behaviourParser, imagingParser, dF_percentile,
% running_speed, timeSeries and allign
%
% set 'imagingPath' as the path to where all the suite2p processed imaging
% information is stored. Each mouse should have its own folder called after
% the name of the mouse. Otherwise the folder structure in this directory
% is irrelevant as all information about the mouse is contained in the dat
% file

% set 'behaviourPath' as the path corre2sponding to the variable 'outPath'
% in the python function 'workflow_behav.py'. Again mice must be in a
% folder with their name but folder structure does not matter otherwise.

% set 'savePath' as the path where the final structures will be saved.
% data is saved as a mat file with the behaviour and imaging data seperate.
% the pipeline function can also be used within matlab to return the
% structure 'data' containing both imaging and behaviour

% all of these paths must end with a '/' this can be responsible for
% a variety of errors


imagingPath = '/home/jamesrowland/Documents/ProcessedData/imaging/2018/';
behaviourPath = '/media/jamesrowland/DATA/RawData/Behaviour/2018/';

savePathBehav = '/home/jamesrowland/Documents/ProcessedData/behaviour_test/';
savePathIm = '/home/jamesrowland/Documents/ProcessedData/test_pipeline/';


% get the appropriate file paths
[txts, pcas] = getBehaviourPaths(behaviourPath, mouse);

% extract the important information for behaviours of interest
allSessions = getTasks(txts, pcas);

% rearrange the behaviour so it forms a single structure with dates and
% imaging areas as fieldnames
behavStruct = behaviourParser(allSessions);

% save behavioural data to structure
save([savePathBehav mouse '.mat'], 'behavStruct');

% rearrange all imaging structures from suite 2P to a single structure
% with dates and areas as fieldnames
imStruct = imagingParser(imagingPath, mouse);

% shift the imaging behaviour into the imaging structure, allign to the
% behaviour and generate time series trial by trial data.
if iscell(imStruct) == 0
    imaging = timeSeries(imStruct, behavStruct);   
    % save the combined imaging and behaviour structure
    save([savePathIm mouse '.mat'], 'imaging', '-v7.3');
end
















