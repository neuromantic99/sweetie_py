% function [nonlin, nonlinDeriv]  = sig(x)
%     nonlin = 1 ./ (1 + exp(-x));
%     nonlinDeriv = nonlin .* (1-nonlin);
% end

function [hyptan, hyptan_deriv] = sig(x)
    
    hyptan = tanh(x);
    hyptan_deriv = 1 - hyptan.^2;
    
end

% function [lin, lindiv] = sig(x)
%     lin = purelin(x);
%     lindiv = 1;
% end

    