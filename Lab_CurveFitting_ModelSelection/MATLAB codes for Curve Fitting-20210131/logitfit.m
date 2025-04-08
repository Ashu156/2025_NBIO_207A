%logit_fit.m
%
% Fits parameters by logistic regression to find the Maximum Likelihood of
% the binary data given the fitted probability function.
%
% Data should be in two vectors of equal length, one of x-values and a
% second one of 0s and 1s of the corresponding outputs.
%
%
StartingPars = zeros(1,2);      % Two parameters to estimate

StartingPars(1) = min(x) + rand*(max(x)-min(x));
StartingPars(2) = rand*(max(x)-min(x));

% Ignore this "options" variable for now
%options=optimset('Display','iter');
options=optimset();

ParEstimates = fminsearch(@logitML,StartingPars,options,x,y);

disp(strcat('Estimated x0 , ',num2str(ParEstimates(1))))
disp(strcat('Estimated sigma , ', num2str(ParEstimates(2))))

