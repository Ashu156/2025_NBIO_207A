%   Fit Generalized Linear Model with Probit Link

%   Fit a generalized linear regression model, and compute predicted (estimated) values for the predictor data using the fitted model.
%   Create a sample data set.

% Each y value is the number of successes in the corresponding number of trials in n, and x contains the predictor variable values.

x = [2100 2300 2500 2700 2900 3100 ...
     3300 3500 3700 3900 4100 4300]';
n = [48 42 31 34 31 21 23 23 21 16 17 21]';
y = [1 2 0 3 8 8 14 17 19 15 17 21]';

% Fit a probit regression model for y on x. 
b = glmfit(x,[y n],'binomial','link','probit');

% Compute the estimated number of successes. Plot the percent observed and estimated percent success versus the x values. 
yfit = glmval(b,x,'probit','size',n);
plot(x, y./n,'o',x,yfit./n,'-','LineWidth',2);





