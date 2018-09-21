%to obtain df/f traces run this and comment function below this one. To
%obtain non df/f traces run the second function and comment this one.
 
 function dF=dF_percentile(input)

% mariangela 2017
% calculate (f-f0)/f0. F0 is signal between 10th and 70th percetile 

% calculate F/F0
input=input-min(input);

tmp=prctile(input,[10 70],2);


low_tc=tmp(1);
high_tc=tmp(2);

ind=input>low_tc & input<high_tc;


F0=median(input(ind),2);

dF=(input-F0)/F0;


% function dF=dF_percentile(input)
% 
% 
%  dF = input;
