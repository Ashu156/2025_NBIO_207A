% curve_fitting.m
% This code tries 7 different types of fit to the data
% For each fit, the function "fminsearch" is used to minimize in a
% least-squares sense the difference between function values calculated 
% at the set of points given in the array "x" and the actual data
% in the array "yvals"

% This routine requires that you have made the 7 functions: 
% "sinfit", "expfit", gaussfit", "lorfit", "poly2fit", "poly3fit" and
% "poly4fit" stored in the path or local directory in files with the
% function name and ".m" extension.
% For example "poly4fit" is a function in the file "poly4fit.m".

% First pick which function will be used for fitting
yvals = y7;

% Ignore this "options" variable for now
%options=optimset('Display','iter');
options=optimset();

% Start with random values for the parameters to be fitted
StartingSin=10*rand(1,3); % Sine has 3 parameters: amplitude, frequency and phase
SinEstimates=fminsearch(@sinfit,StartingSin,options,x,yvals)

StartingExp=rand(1,2); % Exponential has 2 parameters, amplitude and decay constant
ExpEstimates=fminsearch(@expfit,StartingExp,options,x,yvals)

StartingGauss=rand(1,3); % Gaussian has 3 parameters: amplitude, center and half-width
GaussEstimates=fminsearch(@gaussfit,StartingGauss,options,x,yvals)

StartingLor=rand(1,3); % Lorentzian has 3 parameters (same as Gaussian)
LorEstimates=fminsearch(@lorfit,StartingLor,options,x,yvals)

StartingPoly2=rand(1,3); % 2nd order polynomial has 3 parameters 
                         % (constant, linear and quadratic terms)
Poly2Estimates=fminsearch(@poly2fit,StartingPoly2,options,x,yvals)

StartingPoly3=rand(1,4); % 3rd order polynoomial
Poly3Estimates=fminsearch(@poly3fit,StartingPoly3,options,x,yvals)

StartingPoly4=rand(1,5); % 4th order polynomial
Poly4Estimates=fminsearch(@poly4fit,StartingPoly4,options,x,yvals)

% In all the above function calls, the optimized parameters are returned in
% "SinEstimates" to "Poly4Estimates"


% To check the fit
clf
plot(x,yvals,'xk','LineWidth',3)  % plot in thick black "x"s
hold on

% Definition of the exponential curve with its best parameters
ExpCurve = ExpEstimates(1)*exp(-ExpEstimates(2)*x);
plot(x,ExpCurve,'g')    % plot in green

% Definition of the sine curve with its best parameters
SinCurve = SinEstimates(1)*sin(SinEstimates(2)*x+SinEstimates(3));
plot(x,SinCurve,'b')     % plot in blue

% Definition of the Gaussian curve with best parameters
GaussCurve = GaussEstimates(1)*exp(-(x-GaussEstimates(2)).*(x-GaussEstimates(2)) ...
    /(2.0*GaussEstimates(3)*GaussEstimates(3)));
plot(x,GaussCurve,'m')      % plot in magenta

% Definition of the best fit Lorentzian curve
LorCurve = LorEstimates(1)./(LorEstimates(2)*LorEstimates(2) + ...
    (x-LorEstimates(3)).*(x-LorEstimates(3)));
plot(x,LorCurve,'c')        % Plot in cyan

% Definition of best fit 2nd order polynomial
Poly2Curve = Poly2Estimates(1)+Poly2Estimates(2)*x+Poly2Estimates(3)*x.*x;
plot(x,Poly2Curve,'b-')     % plot in blue dashes

% Definition of best fit 3rd order polynomial
Poly3Curve = Poly3Estimates(1)+Poly3Estimates(2)*x+Poly3Estimates(3)*x.*x+ ...
    Poly3Estimates(4)*x.*x.*x ;
plot(x,Poly3Curve,'m.')     % plot in magenta dots

% Definition of best fit 4th order polynomial
Poly4Curve = Poly4Estimates(1)+Poly4Estimates(2)*x+Poly4Estimates(3)*x.*x+ ...
    Poly4Estimates(4)*x.*x.*x + Poly4Estimates(5)*x.*x.*x.*x;
plot(x,Poly4Curve,'y')      % plot in yellow

legend('data', 'Exponential', 'Sine', 'Gaussian', 'Lorentzian', ...
    '2nd Order', '3rd Order', '4th Order'); 

SinErr = sum((yvals-SinCurve).*(yvals-SinCurve))
ExpErr = sum((yvals-ExpCurve).*(yvals-ExpCurve))
GaussErr = sum((yvals-GaussCurve).*(yvals-GaussCurve))
LorErr = sum((yvals-LorCurve).*(yvals-LorCurve))
Poly2Err = sum((yvals-Poly2Curve).*(yvals-Poly2Curve))
Poly3Err = sum((yvals-Poly3Curve).*(yvals-Poly3Curve))
Poly4Err = sum((yvals-Poly4Curve).*(yvals-Poly4Curve))
