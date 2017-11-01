fjf = open('/Users/James/Desktop/Python/2017-07-20_17-25-49.mat');
out = getfield(fjf, 'out');

stimMatrix = cell(length(out(1,1,:)),length(out(1,:,1)),length(out(1,1,:)));


for i = 1:240
    
    for iii = 1:length(out(1,1,:))
        xo =  out(i,2,iii);
        
        if xo == 200
            xop = 'opto on';
        elseif xo == 250
            xop = 'opto off';
        elseif xo == 500
            xop = 'whisker on';
        else
            xop = 'whisker off';
        end
        stimMatrix{i,2,iii} = xop;
        stimMatrix{i,1,iii} = out(i,1,iii);
    end
    
end

for i = 1:length(out(:,1,1))
    for ii = 1:length(out(1,:,1))
        for iii = 1:length(out(1,1,:))
            
            if iii == 133
                stimMatrix{i,ii,iii} = [];
                
            elseif iii == 233
                
                if strcmp(stimMatrix{i,2,iii}, 'opto on') == 1 || strcmp(stimMatrix{i,2,iii}, 'opto off') == 1
                    stimMatrix{i,ii,iii} = [];
                end
                
            elseif iii == 1
                
                if strcmp(stimMatrix{i,2,iii}, 'whisker on') == 1 || strcmp(stimMatrix{i,2,iii}, 'whisker off') == 1
                    stimMatrix{i,ii,iii} = [];
                end
            end
        end
    end
end

vo = cell(240,2,4);













%

% end