function percentCorrect = behaviourPlotter(behav, task)

% set path to the complete structures make sure this ends with '/'
fPath = '/home/jamesrowland/Documents/ProcessedData/fullStructures/';

%return information about the session of interest
allSessions = behav.(task);

dates = fieldnames(allSessions);
numSessions = length(dates);

if strcmp(task, 'habituation')
    tasklist = {'habituation_fd', 'habituation'};
end

correct = cell(numSessions,1);
missed = cell(numSessions,1);
fp = cell(numSessions,1);
cr = cell(numSessions,1);


if strcmp(task, 'recognition') || strcmp(task, 'discrimination')
    
    for i=1:numSessions
        
        session = allSessions.(dates{i});
        
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
        set(gca, 'ylim', [0,i+1], 'ytick', (0:1:i+1))
        ylabel('session number')
        xlabel('time (s)')
        
    end
    
    
elseif strcmp(task, 'imaging_stimulation') || strcmp(task, 'imaging_discrimination')  || strcmp(task, 'imaging_recognition')
    
    for i=1:numSessions
        
        date = allSessions.(dates{i});
        
        areas = fieldnames(date);
        
        for ii = 1:length(areas)
            
            session = allSessions.(dates{i}).(areas{ii});
            if strcmp(session.sessionType, 'flavour')
                continue
            end
            
            correct{i,ii} = session.correct_trials(2:end) / 1000;
            missed{i,ii} = session.missed_trials / 1000;
            fp{i,ii} = session.falsepositive_trials / 1000;
            
            if strcmp(task, 'imaging_discrimination')
                cr{i,ii} = session.correctrejection_trials / 1000;
            else
                cr{i,ii} = [];
            end
            
            numCorrect = sum(length(correct{i,ii}) + length(cr{i,ii}));
            numIncorrect = sum(length(missed{i,ii}) + length(fp{i,ii}));
            numTrials = numCorrect + numIncorrect;
            
            percentCorrect(i,ii) = numCorrect/numTrials * 100;
            
            
        end
        
    end
    
    close all
    for ii = 1:length(areas)
        
        figure(ii), hold on
        for i = 1:numSessions
            
            plot(correct{i,ii}, rasterY(correct{i,ii})*i, '.b')
            plot(missed{i,ii}, rasterY(missed{i,ii})*i, '.r')
            plot(fp{i,ii}, rasterY(fp{i,ii})*i, '.m')
            plot(cr{i,ii}, rasterY(cr{i,ii})*i, '.g')
            set(gca, 'ylim', [0,i+1], 'ytick', (0:1:i+1))
            ylabel('session number')
            xlabel('time (s)')
            title(sprintf('area %d', ii))
            
        end
    end
    

elseif contains(task, 'habituation')
    
    close all
    tot_water_deliveries = [];
    figcount = 1;
    % loads of variables are redefined here but i couldnt be bothered
    % to come up with new names
    for t = 1:2
        task = tasklist{t};
        allSessions = behav.(task);
        dates = fieldnames(allSessions);
        numSessions = length(dates);
        
        
        for i=1:numSessions
            figcount = figcount+1;
            session = allSessions.(dates{i});
            
            mid_time_bin = session.mid_time_bin;
            speed = session.speed;
            
            figure(figcount), hold on
            plot(mid_time_bin,speed,'k');
            xlabel('time (s)')
            ylabel ('speed (cm/s)')
            if strcmp(task, 'habituation_fd')
                title (strcat({'Habituation First Day'}, {' '}, {int2str(figcount - 1)}))
            else
                title (strcat({'Habituation Day'},{' '}, {int2str(figcount - 1)}))
            end
            
            licks = session.licks;
            water_delivered = session.water_delivered;
            
            y_values_licks = ones (1,length(licks)) * 5; %plot licks always at 5 on the y axis.
            y_values_water = ones (1,length(water_delivered)) * 5.2; %plot water rewards always at 5.2 on the y axis.
            figure(figcount); hold on
            plot(licks, y_values_licks, '.r')
            plot(water_delivered, y_values_water, '.b')
            
            % only count the total number of water deliveries
            if strcmp(task, 'habituation')
                % the total number of water deliverys across sessions
                tot_water_deliveries=[tot_water_deliveries length(water_delivered)];
            end
            
        end
        
    end
    
    proportion_over_sessions = [];
    max_water=max(tot_water_deliveries);
    
    for i=1:length(tot_water_deliveries)
        proportion_over_sessions=[proportion_over_sessions (tot_water_deliveries(i)*100/max_water)];
    end
    
    figure(1)
    plot (proportion_over_sessions, '-o','Color','b', 'MarkerSize', 10)
    set(gca,'ylim', [-10 110], 'xlim', [0 numSessions+1]);
    xlabel('session (day)')
    ylabel ('% of water in best session')
    title('Performance over days - habituation only')
    percentCorrect = [];
    
end

    function yaxis = rasterY(x)
        yaxis = ones(1,length(x));
    end

end



