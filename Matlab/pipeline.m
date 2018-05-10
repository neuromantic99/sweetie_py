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
behaviourPath = '/home/jamesrowland/Documents/ProcessedData/behaviour/2018/';

savePath = '/home/jamesrowland/Documents/ProcessedData/';

%make apprporiate subfolders if they dont exist
if ~exist([savePath '/ca-data-large/2018'])
    mkdir([savePath '/ca-data-large/2018'])
end

if ~exist([savePath '/fullStructuresBehaviour/'])
    mkdir([savePath '/fullStructuresBehaviour/'])
end

fNameImaging = [savePath '/ca-data-large/2018/' mouse '.mat'];
fNameBehaviour = [savePath '/fullStructuresBehaviour/2018/' mouse '.mat'];


% run master imaging and behaviour functions
imaging = imagingParser(imagingPath, mouse);
behaviour = behaviourParser(behaviourPath, mouse);


% use behaviourPlotter to plot raster plots of behaviour
% task should be set to the behaviour of interest e.g. 'habituation'
%task = 'imaging_discrimination';
%pc = behaviourPlotter(behaviour, task);

% save behavioural data to structure
save(fNameBehaviour, 'behaviour');

% shift the imaging behaviour into the imaging structure, allign to the
% behaviour and generate time series trial by trial data.
if iscell(imaging) == 0
    imaging = timeSeries(imaging, behaviour);   
    save(fNameImaging, 'imaging', '-v7.3');
end


end


