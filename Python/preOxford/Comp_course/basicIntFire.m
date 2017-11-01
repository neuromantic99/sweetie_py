% initialise the variables
E =  -70;
Rm = 10;
taum = 10;
V = zeros(3000,1);
V(1) = E;
vreset = -80;
threshold = -54;

tmax = 300;
tstep = 0.1;
num_spikes = 0;
%Ie = 3;

Ie_iter = linspace(0,5,100);


for ix = 1:length(Ie_iter)
    
    Ie = Ie_iter(ix);

for i = 2:tmax/tstep

    V(i) = V(i-1) + tstep * ((E - V(i-1) + Rm * Ie) / taum);

    if V(i) > threshold
        V(i-1) = 20;
        num_spikes = num_spikes + 1;
        V(i) = -80;
    end

end
spikes_save(ix) = num_spikes;
 
end


pIe_iter = linspace(1.7,15,100);

for i = 1:length(pIe_iter)
    p_Ie = pIe_iter(i);

    numerator = Rm*p_Ie + E - vreset;
    denomenator = Rm* p_Ie + E - threshold;
    isi(i) = log(numerator/denomenator)^-1;
    
end


V = transpose(V);

non_stim = repelem(-80,1000);

V = [non_stim V];
V = [V non_stim];

figure
plot(V)


% close all, figure
% plot(Ie_iter,spikes_save)


