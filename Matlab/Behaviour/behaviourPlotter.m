mouse = 'GTRS1.1a';

as = behaviourParser(mouse);

test = as.habituation.d2017_10_12;

licks = test.licks;
water_delivered = test.water_delivered;

proportion_over_sessions = as.proportion_over_sessions;


y_values_licks = ones (1,length(licks)) * 5; %plot licks always at 5 on the y axis.
y_values_water = ones (1,length(water_delivered)) * 5.2; %plot water rewards always at 5.2 on the y axis.
figure(); hold on
plot(licks, y_values_licks, '.r')
plot(water_delivered, y_values_water, '.b')


figure(1)
plot (proportion_over_sessions, '-o','Color','b', 'MarkerSize', 10)
title (mouse)
set(gca,'ylim', [-10 110], 'xlim', [0 (length(files)+1)]);
xlabel('session (day)')
ylabel ('% of water in best session')

figure;hold on

plot(mid_time_bin,speed,'k');
set(gca,'ylim', [-1 10],'xlim', [0 end_of_session]);%,'xticklabel', [time (s)], 'yticklabel', [speed(degrees/30s)]);
xlabel('time (s)')
ylabel ('speed (cm/s)')
