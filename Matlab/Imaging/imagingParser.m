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
    dFoF=[];
    %store whether cell is labelled red. 0= no red labelling; 1= red labelling.
    is_red_neuron=[]; 
    %deconvolved spike times in frames
    all_spike_times={}; 
    %amplitudes of the deconvovled spikes
    all_spike_amps = {};
    %position of the neuron in (x,y) coordinates
    neuron_position=[];
    
    
    %Suite2p gives a neuropil coefficient (r) for each ROI.
    %Calculate the mean r for each plane, for each area acquired.
    %This should be the neuropil coefficiennt described in Chen, 2013 and Kerlin, 2010
    
  %  keyboard
    
    r_coefficient = mean([dat.stat.neuropilCoefficient]);
    for kk = 1:length(dat.stat)
        if dat.stat(kk).iscell
            
            %maris code to represent spike times as a binary vector
            %spike_timings=zeros(1,length(dat.Fcell{:}));
            %spike_timings(dat.stat(kk).st)= dat.stat(kk).c;
            
            %jims code to not do that (change horrible try loop)
            try
                spike_timings = dat.stat(kk).st;
                spike_amps = dat.stat(kk).c;
            catch
                spike_timings = [];
                spike_amps = [];
            end
            
            
            
            ROIs_corrected=[ROIs_corrected; (dat.Fcell{:}(kk,:)-(dat.FcellNeu{:}(kk,:)*r_coefficient))]; %subtract neuropil as in Chen, 2013-nature methods
            is_red_neuron=[is_red_neuron; dat.stat(kk).redcell];
            all_spike_times=[all_spike_times; spike_timings];
            all_spike_amps = [all_spike_amps; spike_amps];
            
            %for each ROI, call the function (dF_percentile) that calculates f-f0/f0.
%             for nn = 1: size (ROIs_corrected,1)
%                 dFoF = [dFoF; dF_percentile(ROIs_corrected(nn,:))]; 
%             end
            
            dFoF = ROIs_corrected;
          
            neuron_position=[neuron_position; dat.stat(kk).med]; % for each roi, first column is the x median and second column in y median.
        end
    end
    
    % create a string with the region and plane number that is a valid structure field
    % name (remove space from region in case there is multilple regions in
    % a single file
    planeStr = ['plane' int2str(plane)];
    
    regionStr = ['area' int2str(region)];
    regionStr = regionStr(find(~isspace(regionStr)));
    
    % create a date string that is a vaid structure name and matches
    % that yielded by the behaviour
    date = insertAfter(date, 4, '_');
    date = insertAfter(date, 7, '_');
    dateStr = ['date_' date];

    % get the frame rate
    fRate = dat.ops.imageRate;
    %divide the frame rate by the number of planes to get
    %the frame rate at individual frames
    nPlanes = dat.ops.nplanes;
    fRate = fRate / nPlanes;
    
    
    % build the imaging structure with the dynamic field names
    % corresponding to the area (region) and plane
    imaging.(dateStr).(regionStr).(planeStr).raw_fluoresence = dat.Fcell;
    imaging.(dateStr).(regionStr).(planeStr).spike_timings = all_spike_times;
    imaging.(dateStr).(regionStr).(planeStr).spike_amps = all_spike_amps;
    
    imaging.(dateStr).(regionStr).(planeStr).fluoresence_corrected = dFoF;
    imaging.(dateStr).(regionStr).(planeStr).position = neuron_position;
    imaging.(dateStr).(regionStr).(planeStr).is_red = is_red_neuron;
    imaging.(dateStr).(regionStr).(planeStr).fRate = fRate;

end

end
%
