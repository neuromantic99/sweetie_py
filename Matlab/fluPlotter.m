session = im.date_2017_12_13.area1;

mtb = session.session_behaviour.mid_time_bins;
re = session.session_behaviour.runEvents;

flu = session.plane2.fluoresence_corrected;

mFlu = nanmean(flu);

nFrames = length(flu);

maxSecs = nFrames / session.plane2.fRate;


close all

nPlots = 5;

for i = 1:nPlots
    
    s1 = subplot(nPlots+1,1,i);
    plot(linspace(0,maxSecs,length(mFlu)),flu(i+15,:))
    set(gca, 'xlim', [0,maxSecs], 'ytick', [], 'xtick', [])
    
    s2 = subplot(nPlots+1,1,nPlots+1);
    plot(mtb,re)
    set(gca, 'xlim', [0,maxSecs], 'xtick', [])

    
end