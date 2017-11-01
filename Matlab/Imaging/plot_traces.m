function imaging = (imagingParser)

fPath = '/Volumes/KohlLab/JamesR/Suite2p_processed/F_VIP39.4a_20171006_plane1_proc.mat';


load(fPath);

imaging = {};

ROIs_corrected=[]; %Rois signal corrected for neuropil
dF_calcium_traces=[];
is_red_neuron=[]; %for each ROI that we're going to save, keep a note about red labelling. 0= no red labelling; 1= red labelling.
spike_traces=[]; %this is from dat.st: indicates the deconvolved spike times (in frames)
neuron_position=[];


%Suite2p gives a neuropil coefficient (r) for each ROI.
%Calculate the mean r for each plane, for each area acquired.
%This should be the neuropil coefficiennt described in Chen, 2013 and Kerlin, 2010
for thisplane = 1:2
    
    r_coefficient = mean([dat.stat.neuropilCoefficient]);
    for kk = 1:length(dat.stat)
        if dat.stat(kk).iscell
            spike_timings=zeros(1,length(dat.Fcell{1,thisplane}));
            spike_timings(dat.stat(kk).st)= dat.stat(kk).c;
            ROIs_corrected=[ROIs_corrected; (dat.Fcell{1,thisplane}(kk,:)-(dat.FcellNeu{1,thisplane}(kk,:)*r_coefficient))]; %subtract neuropil as in Chen, 2013-nature methods
            is_red_neuron=[is_red_neuron; dat.stat(kk).redcell];
            spike_traces=[spike_traces; spike_timings];
            neuron_position=[neuron_position; dat.stat(kk).med]; % for each roi, first column is the x median and second column in y median.
        end
    end
    
    

   
end

end
    
