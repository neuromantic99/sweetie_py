ender = max(stim1(:,1,2));

added = stim2(:,1,:) + ender;
added(:,2,:) = stim2(:,2,:);


combine = cat(3,stim1, added);