function data = pipeline(mouse)

% Pipeline to generate the structure containing all the information
% (behaviour and imaging about a mouse.

% Requires the functions: behaviourParser, imagingParser, dF_percentile,
% running_speed
% 
% set 'imagingPath' as the path to where all the suite2p processed imaging
% information is stored. Each mouse should have its own folder called after
% the name of the mouse. Otherwise the folder structure in this directory
% is irrelevant as all information about the mouse is contained in the dat
% file

% set 'behaviourPath' as the path corresponding to the variable 'outPath'
% in the python function 'workflow_behav.py'. Again mice must be in a
% folder with their name but folder structure does not matter otherwise.

% set 'savePath' as the path where the final structures will be saved.
% data is saved as a mat file with the behaviour and imaging data seperate.
% the pipeline function can also be used within matlab to return the
% structure 'data' containing both imaging and behaviour

% all of these paths must end with a '/' this can be responsible for 
% a variety of errors
imagingPath = '/home/jamesrowland/Documents/ProcessedData/imaging/';
behaviourPath = '/home/jamesrowland/Documents/ProcessedData/behaviour/';
savePath = '/home/jamesrowland/Documents/ProcessedData/fullStructures/';

try
    imaging = imagingParser(imagingPath, mouse);
    behaviour = behaviourParser(behaviourPath, mouse);

    

    data = {};

    data.imaging = imaging;
    data.behaviour = behaviour;

    fName = [savePath mouse '.mat'];
    save(fName, 'imaging', 'behaviour');

catch
    disp(mouse)



end


