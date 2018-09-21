function arr =  debounce(arr, deb_time)

% recursive function to debounce the trial types in case they are printed multiple times
a1 = arr(1:end-1);
a2 = arr(2:end);

% the difference between each value in the array
subbed = a2 - a1;

% find differences less than the dedbounce threshold
bounced = find(subbed <= deb_time);

% if bounced is empty, there is no debouncing so return array in current
% state
% else remove the first bounced value and call the function again
if isempty(bounced)
    return
else
    arr(bounced(1) + 1) = [];
    arr = debounce(arr, deb_time);
end

end