% binary_data.m
%
% Produces binary data (1s or 0s) probabilistically according to a
% specified function of a control parameter.
% For example, this could be results of a test of stimulus detection (1 =
% detected, 0 = not detected) where the control parameter would be
% strength of stimulus (eg signal to noise ratio).
%
%
Nvals = 100;

xmin = 0;
xmax = 10;

x = xmin + (xmax-xmin)*rand(1,Nvals);

sigma = 2;  % range over which detection increases from 0 to 1
x0 = 4;     % threshold for detection

f_of_x = 1./( 1+exp( (x0-x)/sigma ) );     % logistic function

y = rand(size(x)) < f_of_x;

figure(1)
plot(x,f_of_x,'x')
figure(2)
plot(x,y,'x')



