function [imaging, behavStruct] = pipeline(mouse)

% Pipeline to generate the structure containing all the information
% (behaviour and imaging about a mouse.

% Requires all matlab functions in the I-just-kohld-to-say-i-love-you repo

% set 'imagingPath' as the path to where all the suite2p processed imaging
% information is stored. Each mouse should have its own folder called after
% the name of the mouse. Otherwise the folder structure in this directory
% is irrelevant as all information about the mouse is contained in the dat
% file

%set 'imagingPath' as the path to the proc files coming from suite2p

% set 'behaviourPath' as the path to the raw txt and PCA files outputted from
% pyControl folder structure does not matter

% set 'savePathBehav' as an existing folder where the behavioral structure
% should be saved

% set 'savePathIm' as an existing folder where the combined and aligned
% imagng and behaviour structure will be saved

% all of these paths must end with a '/' this can be responsible for
% a variety of errors

fclose all;

imagingPath = 'C:\Users\Curtis-E-Bear\Desktop\data\imaging\';
behaviourPath = 'C:\Users\Curtis-E-Bear\Desktop\data\organised_behaviour\';

savePathBehav = 'C:\Users\Curtis-E-Bear\Desktop\data\processed\behaviour\';
savePathIm = 'C:\Users\Curtis-E-Bear\Desktop\data\processed\imaging\';

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
if ~iscell(imStruct)
    imaging = timeSeries(imStruct, behavStruct);   
    % save the combined imaging and behaviour structure
    save([savePathIm mouse '.mat'], 'imaging', '-v7.3');
else
    imaging = [];
end

