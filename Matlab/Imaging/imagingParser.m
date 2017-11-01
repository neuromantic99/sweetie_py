function imaging = imagingParser(fPath, mouse)

fPath= [fPath mouse '/'];

%get all the mat files that result from gui editing in suite 2p
allMats = dir([fPath  '**/*proc.mat']);

% create the structure to hold processed imaging data
imaging = {};
    
for i = 1:length(allMats)
    
    % load the dat file from an imaging session
    session = allMats(i);
    f = load([session.folder '/' session.name]);
    dat = f.dat;
    
    % get the plane number - stored as the 'iplane' variable in the ops
    % file
    plane = dat.ops.iplane;
    
    % get the area number - stored as the 'expts' variable in the ops file
    region = dat.ops.expts;
    
    % get the date the imaging was performed
    date = dat.ops.date;
    
    %Rois signal corrected for neuropil
    ROIs_corrected=[];
    dF_calcium_traces=[];
    %store whether cell is labelled red. 0= no red labelling; 1= red labelling.
    is_red_neuron=[]; 
    %deconvolved spike times in frames
    spike_traces=[]; 
    %position of the neuron in (x,y) coordinates
    neuron_position=[];
    
    
    %Suite2p gives a neuropil coefficient (r) for each ROI.
    %Calculate the mean r for each plane, for each area acquired.
    %This should be the neuropil coefficiennt described in Chen, 2013 and Kerlin, 2010

    
    r_coefficient = mean([dat.stat.neuropilCoefficient]);
    for kk = 1:length(dat.stat)
        if dat.stat(kk).iscell
            spike_timings=zeros(1,length(dat.Fcell{1,plane}));
            spike_timings(dat.stat(kk).st)= dat.stat(kk).c;
            ROIs_corrected=[ROIs_corrected; (dat.Fcell{1,plane}(kk,:)-(dat.FcellNeu{1,plane}(kk,:)*r_coefficient))]; %subtract neuropil as in Chen, 2013-nature methods
            is_red_neuron=[is_red_neuron; dat.stat(kk).redcell];
            spike_traces=[spike_traces; spike_timings];
            neuron_position=[neuron_position; dat.stat(kk).med]; % for each roi, first column is the x median and second column in y median.
        end
    end
    
    % create a string with the region and plane number that is a valid structure field
    % name (remove space from region in case there is multilple regions in
    % a single file
    planeStr = ['plane' int2str(plane)];
    
    regionStr = ['region' int2str(region)];
    regionStr = regionStr(find(~isspace(regionStr)));
    
    dateStr = ['date_' date];
    
    % build the imaging structure with the dynamic field names
    % corresponding to the area (region) and plane
    imaging.(dateStr).(regionStr).(planeStr).raw_fluoresence = dat.Fcell;
    imaging.(dateStr).(regionStr).(planeStr).spike_timings = spike_traces;
    imaging.(dateStr).(regionStr).(planeStr).fluoresence_corrected = ROIs_corrected;
    imaging.(dateStr).(regionStr).(planeStr).position = neuron_position;
    imaging.(dateStr).(regionStr).(planeStr).is_red = is_red_neuron;
   
    
    
  %  keyboard
end

end
%
