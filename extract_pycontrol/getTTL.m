function TTLs = getTTL(session)

% extracts the TTL in and out times and makes them into one array
if ~isfield(session.times, 'TTL_in')
    TTLs = [];
    return
end

in = session.times.TTL_in;
out = session.times.TTL_out;

TTLs = zeros(2, length(in));

TTLs(1,:) = in;
TTLs(2,:) = out;

