session = im.date_2017_11_28.area2;

mtb = session.session_behaviour.mid_time_bins;
re = session.session_behaviour.runEvents;

flu = session.plane1.fluoresence_corrected;

[C,I] = max(flu(:));
[I1,I2] = ind2sub(size(flu),I);

flav = im.date_2017_11_28.area2.session_behaviour.flavourA;
flav2 = im.date_2017_11_28.area2.session_behaviour.flavourB;


mFlu = nanmean(flu);

nFrames = length(flu);



close all, 
nPlots = 10;

for fig = 1:5
    hold on

    figure(fig)
    
    for i = 1:nPlots
        
        s1 = subplot(nPlots+1,1,i);
        
        plot(flu(i+(nPlots*fig),:))
        hold on
        %set(gca, 'xlim', [0,maxSecs], 'xtick', [])
        set(gca, 'ylim', [-2,2])
        plot(flav, zeros(length(flav))+2, '.r')
        set(gca, 'ylim', [-2,2])
        plot(flav2, zeros(length(flav2))+2, '.g')
%         s2 = subplot(nPlots+1,1,nPlots+1);
%         plot(mtb,re)
%         set(gca, 'xlim', [0,maxSecs], 'xtick', [])


    end
    
end