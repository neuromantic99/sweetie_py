clear

% set path to the complete structures make sure this ends with '/'
fPath = '/home/jamesrowland/Documents/ProcessedData/fullStructures/';

% the name of the mouse of interest
mouse = 'VIP41.3a';

% the date of the session of interest in format: yyyy_mm_dd
%date = '2017_10_12';

% the type of behaviour of interest - currently: habituation,
% discrimination,  imaging stimulation, imaging discrimination,
task = 'discrimination';


% load all behavioural data for the animal
f = load([fPath mouse '.mat']);
behav = f.behaviour;

% change date to correct format
%date = strcat('date_',date);

%return information about the session of interest
allSessions = behav.(task);
fields = fieldnames(allSessions);
numSessions = length(fields);

correct = cell(numSessions,1);
missed = cell(numSessions,1);
fp = cell(numSessions,1);
cr = cell(numSessions,1);
%percentCorrect = zeros(numSessions, 1);

for i=1:numSessions
    
    session = allSessions.(fields{i});
    
    
    correct{i} = session.correct_trials(2:end) / 1000;
    missed{i} = session.missed_trials / 1000;
    fp{i} = session.falsepositive_trials / 1000;
    
    if strcmp(task, 'discrimination')
        cr{i} = session.correctrejection_trials / 1000;
    else
        cr{i} = [];
    end
    
    numCorrect = sum(length(correct{i}) + length(cr{i}));
    numIncorrect = sum(length(missed{i}) + length(fp{i}));
    numTrials = numCorrect + numIncorrect;
    
    percentCorrect(i) = numCorrect/numTrials * 100;
    
end
    
% plot the outcomes of the sessions
close all, figure, hold on
for i = 1:numSessions
       
    plot(correct{i}, rasterY(correct{i})*i, '.b')
    plot(missed{i}, rasterY(missed{i})*i, '.r')
    plot(fp{i}, rasterY(fp{i})*i, '.y')
    plot(cr{i}, rasterY(cr{i})*i, '.g')
end


function yaxis = rasterY(x)
    yaxis = ones(1,length(x));
end


    
    
    
    
    % % get the variables for plotting out of the structure
    % licks = session.licks;
    % water_delivered = session.water_delivered;
    % proportion_over_sessions = behav.proportion_over_sessions;
    % %
    %
    % y_values_licks = ones (1,length(licks)) * 5; %plot licks always at 5 on the y axis.
    % y_values_water = ones (1,length(water_delivered)) * 5.2; %plot water rewards always at 5.2 on the y axis.
    % figure(); hold on
    % plot(licks, y_values_licks, '.r')
    % plot(water_delivered, y_values_water, '.b')
    %
    %
    % figure(1)
    % plot (proportion_over_sessions, '-o','Color','b', 'MarkerSize', 10)
    % title (mouse)
    % set(gca,'ylim', [-10 110], 'xlim', [0 (length(files)+1)]);
    % xlabel('session (day)')
    % ylabel ('% of water in best session')
    %
    % figure;hold on
    %
    % plot(mid_time_bin,speed,'k');
    % set(gca,'ylim', [-1 10],'xlim', [0 end_of_session]);%,'xticklabel', [time (s)], 'yticklabel', [speed(degrees/30s)]);
    % xlabel('time (s)')
    % ylabel ('speed (cm/s)')
