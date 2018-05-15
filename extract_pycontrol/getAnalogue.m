function ana = getAnalogue(fPath)

fileID = fopen(fPath);

format = 'int32';
endian = 'ieee-le';
data = fread(fileID, Inf, format, 0, endian);

ana = zeros(length(data)/2 , 2);

ana(:,1) = data(1:2:end);
ana(:,2) = data(2:2:end);







