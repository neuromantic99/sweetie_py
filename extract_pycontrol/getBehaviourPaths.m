function [mouseTxts, mousePcas] = getBehaviourPaths(behaviourPath, mouseName)

% returns a structure will the file path info for the mouse 'mouseName' in
% the path 'behaviourPath'
% this currently returns a cell array of structures which is not ideal
% but works


txts = dir([behaviourPath '/' '**/*.txt']);

mouseTxts = {};

for i = 1:length(txts)
    t = txts(i).name;
  
    if contains(t, mouseName)
         mouseTxts{end+1} = txts(i);
    end
    
end

% get the PCA files corresponding to a given behaviour
pcas = dir([behaviourPath '/' '**/*.pca']);
mousePcas = {};

for i = 1:length(mouseTxts)
    
    % remove the extension from the file name so as to match to pca
    t = mouseTxts{i}.name;
    t = t(1:end-4);
    
    for ii = 1:length(pcas)
        
        p = pcas(ii).name;

        if contains(p, t)
            mousePcas{i} = pcas(ii);        
        end        
    end 
end
    