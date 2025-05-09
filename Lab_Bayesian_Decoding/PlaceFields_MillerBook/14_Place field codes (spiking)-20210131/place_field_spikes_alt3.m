% place_field_spikes.m
%
% Code to estimate position based on combining the probability
% distributions from spikes and from prior position.
% First place fields are defined as circular Gaussians (equal variance in
% x- and y-directions, for a small number of cells.
% Next, a trajectory is produced.
% First half of trajectory is used to estimate the place fields.
% Second half is estimated from the spikes and from the prior position
% estimates.
%
% This code is used to produce Figure 9.9 in the text book 
% "An Introductory Course in Computational Neuroscience" 
% by Paul Miller, Brandeis University (2017).
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear;                  % Clear prior variables from memory
rng(1);                 % Initialize random number generator for reproducibility

xvals = 1:100;          % Grid-points in the x-direction
yvals = 1:100;          % Grid-points in the y-direction
Nx = length(xvals);     % Number of points in x-direction
Ny = length(yvals);     % Number of points in y-direction

% The next line sets up 2 arrays, each covering two-dimensional space, the 
% first containing the x-coordinates, the seconf containing y-coordinates
[xgrid, ygrid] = meshgrid(xvals,yvals); 

%% Now define the place-fields of four cells

% Each row is an (x,y) coordinate pair for the center of a place-field
place_centers = [20 20; 35 60; 70 10; 85 75];

widths = [20 30 ; 15 35; 30 30; 40 10];      % standard deviation of elliptical Gaussians
thetas = [30; 30; 60; 60];      % angles of 1st axis from vertical
rmax = [ 10; 15; 20; 15];       % maximum rate at center of place-field
Ncells = length(rmax);          % number of cells is 4

place_fields = zeros(Nx,Ny,Ncells); % Array to contain all place-fields

for cell = 1:Ncells            % Calculate place-field of each cell
    % The next line implements a circular Gaussian, centered on the x- and
    % y-coordinates of the place-field center for each cell
    xdev_grid = xgrid-place_centers(cell,1);
    ydev_grid = ygrid-place_centers(cell,2);
    x1_grid = xdev_grid*cos(thetas(cell)) + ydev_grid*sin(thetas(cell));
    x2_grid = -xdev_grid*sin(thetas(cell)) + ydev_grid*cos(thetas(cell));
    
    place_fields(:,:,cell) = rmax(cell) * ...
        exp(-( x1_grid.^2)/(2*widths(cell,1)^2 ) - (x2_grid.^2) /(2*widths(cell,2)^2 ) );
    
    figure(cell)    % Plot the place-field of each cell
    subplot(1,2,1)
    imagesc(squeeze(place_fields(:,:,cell)));
    colorbar
    xlabel('x posn')
    ylabel('y posn')
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now produce a trajectory as a random walk.
%
dt = 0.02;                  % Size of time-bin
t = 0:dt:1800;              % Vector of time-points
Nt = length(t);             % Number of time-points
position = zeros(Nt,2);     % To store x- and y-coordinates of actual position
position(1,:) = [1,1];      % Initial position

spikes = zeros(Ncells,Nt);  % Record presence or absence of spike as 1 or 0

for i = 2:Nt;               % Loop through time-points
    xchange = round(2*rand()-1);    % Produces -1 or 0 or 1 with probs 0.25 0.5 0.25
    ychange = round(2*rand()-1);    % Produces -1 or 0 or 1 with probs 0.25 0.5 0.25  

    % The next two lines ensure 0<x<Nx+1 and 0<y<Ny+1
    % i.e. no movement if suggested move is beyond the boundary
    newx = max(min(position(i-1,1)+xchange,Nx),1);
    newy = max(min(position(i-1,2)+ychange,Ny),1);

    position(i,:) = [newx newy];    % Update position with new values
    
    % In the next line produce a spike with probability of rate*dt for each
    % cell based on its place-field and the actual position
    spikes(:,i) = rand(Ncells,1) < dt*squeeze(place_fields(newy,newx,:));
end
prob_spike = mean(spikes,2)

%% Now use the first half of the data to estimate the place-fields

%   First accrue the time spent at each position

thalf = round(Nt/2);        % Time-point ending first half of data
x_inputs = position(1:thalf,1);
y_inputs = position(1:thalf,2);

% Ignore this "options" variable for now
%options=optimset('Display','iter');
options=optimset();

% Now count the spikes produced per cell at each position
for cell = 1:Ncells;                % Loop through each of the cells
    % First fit a circular Gaussian then go to a general 2D one
    StartingGaussCirc = [1 100 100 20].*rand(1,4);
    GaussCircEstimates=fminunc(@gauss_circLL,StartingGaussCirc,options, ...
        [x_inputs, y_inputs],spikes(cell,1:thalf))
    
    amp_est1(cell) = GaussCircEstimates(1);     % Estimate of rate*dt at center
    x0_est1(cell) = GaussCircEstimates(2);      % x-xoordinate of center
    y0_est1(cell) = GaussCircEstimates(3);      % y-coordinate of center
    sig_est1(cell) = GaussCircEstimates(4);     % s.d. of Gaussian
    
    % Use as initial conditions the best fits for the circular Gaussian,
    % then pick a random angle.
    StartingGauss2D=[amp_est1(cell) x0_est1(cell) y0_est1(cell) ...
        sig_est1(cell) sig_est1(cell) pi/6]; % 2D Gaussian has 6 parameters: amplitude,center and half-width

    Gauss2DEstimates=fminunc(@gauss2DLL,StartingGauss2D,options,[x_inputs, y_inputs],spikes(cell,1:thalf))

    amp_est(cell) = Gauss2DEstimates(1);        % Estimate of rate*dt at center
    x0_est(cell) = Gauss2DEstimates(2);         % x-xoordinate of center
    y0_est(cell) = Gauss2DEstimates(3);         % y-coordinate of center
    sig1_est(cell) = Gauss2DEstimates(4);       % s.d. along axis 1
    sig2_est(cell) = Gauss2DEstimates(5);       % s.d. along axis 2
    theta_est(cell) = Gauss2DEstimates(6);      % angle between x-axis and axis 1
    center_est(cell,:) = [x0_est(cell), y0_est(cell)];  % x,y coordinates of center
    
end

% Now calculate an estimate of the probability of each cell firing when at
% a given location based on the 2D Gaussian place field
spike_fields = zeros(size(place_fields));       % for probability of spike
nospike_fields = zeros(size(place_fields));     % for probability of no spike
est_place_fields = zeros(size(place_fields));   % an estimate of the place-field

for cell = 1:Ncells;                % Loop through all the cells
    
    % First get position relative to center of place field
    xdev = xgrid - x0_est(cell);  
    ydev = ygrid - y0_est(cell);
    
    % Then rotate the axis by theta from x to x1 and from y to x2
    x1 = xdev*cos(theta_est(cell)) + ydev*sin(theta_est(cell));
    x2 = -xdev*sin(theta_est(cell)) + ydev*cos(theta_est(cell));
    
    % Use fitted parameters for the elliptical Gaussian as an estimate
    spike_fields(:,:,cell) = ...
        exp(- x1.^2/(2*sig1_est(cell)^2) ...
         - x2.^2/(2*sig2_est(cell)^2 ) ); 
    
    % spike_fields is probability of a spike when in a particular location,
    % so should be normalized -- here by multiplying by (Nx*Ny) we assume
    % implicitly that the probability of being at any location is equal at
    % 1/(Nx*Ny) so that we have used Bayes' Theorem:
    % P(spike|location) = P(location|spike)*P(spike)/P(location)
    spike_fields(:,:,cell) = prob_spike(cell)*spike_fields(:,:,cell) ...
        *Nx*Ny/sum(sum(spike_fields(:,:,cell)));

    % The probability of no spike in a location is 1 - probability of a
    % spike in that location per time-bin
    nospike_fields(:,:,cell) = (1-spike_fields(:,:,cell));
    
    % Convert spike probability per time bin to a rate for estimated
    % place-field
    est_place_fields(:,:,cell) = spike_fields(:,:,cell)/dt;

    % Plot the estimated place-field on a panel beside the actual
    % place-field
    figure(cell)
    subplot(1,2,2)
    imagesc(squeeze(est_place_fields(:,:,cell)));
    colorbar
    title('Estimated place field')
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Now use estimated place fields to update estimates of positions given
%   spikes and given current position estimates.

prior = ones(size(xgrid))/(Nx*Ny);      % Start with uniform prior

move_prior = zeros(size(xgrid));        % To be updated each time-step
xyest = zeros(Nt-thalf,2);          % Array to estimate x- and y-coordinates

for i = thalf+1:Nt;                 % Loop through all time points
    
    % First use the previous probability estimate of position to produce a
    % prior on the current probability distribution, taking into account
    % the probability of movement in different directions.
    % In this case we have 9 possible new positions given the old position:
    %  NW (1/16) N (1/8)  NE(1/16)
    %   W (1/8)  0 (1/4)  E (1/8)
    %  SW (1/16) S (1/8)  SE(1/16)
    
    
    move_prior = 0.25*prior;        % probability of no change is 0.25
    
    move_prior(1:Ny-1,:) = move_prior(1:Ny-1,:) + prior(2:Ny,:)/8;  % down
    move_prior(2:Ny,:) = move_prior(2:Ny,:) + prior(1:Ny-1,:)/8;    % up
    move_prior(:,1:Nx-1) = move_prior(:,1:Nx-1) + prior(:,2:Nx)/8;  % left
    move_prior(:,2:Nx) = move_prior(:,2:Nx) + prior(:,1:Nx-1)/8;    % right
    
    % Add probabilities of diagonal moves (1/16 each)
    move_prior(1:Ny-1,1:Nx-1) = move_prior(1:Ny-1,1:Nx-1) + prior(2:Ny,2:Nx)/16;
    move_prior(2:Ny,1:Nx-1,:) = move_prior(2:Ny,1:Nx-1,:) + prior(1:Ny-1,2:Nx)/16;
    move_prior(1:Ny-1,2:Nx) = move_prior(1:Ny-1,2:Nx) + prior(2:Ny,1:Nx-1)/16;
    move_prior(2:Ny,2:Nx) = move_prior(2:Ny,2:Nx) + prior(1:Ny-1,1:Nx-1)/16;
    
    % Add additional probabilities of not moving on edge and corner sites
    move_prior(1,:) = move_prior(1,:) + 0.25*prior(1,:);
    move_prior(Ny,:) = move_prior(Ny,:) + 0.25*prior(Ny,:);
    move_prior(:,1) = move_prior(:,1) + 0.25*prior(:,1);
    move_prior(:,Nx) = move_prior(:,Nx) + 0.25*prior(:,Nx);
    
    % Finally remove double counting for corner sites
    move_prior(1,1) = move_prior(1,1) - prior(1,1)/16;
    move_prior(Ny,1) = move_prior(Ny,1) - prior(Ny,1)/16;
    move_prior(1,Nx) = move_prior(1,Nx) - prior(1,Nx)/16;
    move_prior(Ny,Nx) = move_prior(Ny,Nx) - prior(Ny,Nx)/16;
    
    posterior = move_prior;     % Will be recalculated in the next loop
    
    % Now calculate probability based on spikes or no spikes
    for cell = 1:Ncells;        % Loop through all cells
        if ( spikes(cell,i) )   % If the cell spikes
            posterior = posterior.*spike_fields(:,:,cell);
        else;                   % If the cell did not spike
            posterior = posterior.*nospike_fields(:,:,cell);
        end
        
    end
    posterior = posterior./sum(sum(posterior));     % Normalize to 1
    prior = posterior;          % New prior for the next time-bin
  
    % Plot the probability distribution for the estimated location on
    % a subset of time-steps, together with the actual position
    if ( mod(i,100) == 0 )
        figure(10)
        clf
        imagesc(posterior)                      % Probability of positions
        hold on
        plot(position(i,1),position(i,2),'xr')  % Actual position
        title('Position estimate and actual')
        drawnow
    end
    
    % Separately calculate estimates of the x-coordinate and y-coordinate
    % for later comparison with the actual coordinates
    maximum = max(max(posterior));
    [xyest(i-thalf,2) xyest(i-thalf,1)] = find(posterior == maximum);
end

%% Finally calculate a couple of scores to assess how well position was tracked 
xxc = corr(xyest(:,1),position(thalf+1:end,1))
yxc = corr(xyest(:,2),position(thalf+1:end,2))
score = (yxc+xxc)/2

% print out the root-mean-square of the error in position
rt_mean_sqr_err = sqrt(mean((xyest(:,1)-position(thalf+1:end,1)).^2 ...
    + (xyest(:,2)-position(thalf+1:end,2)).^2 ) )


%% Set up the plotting parameters and plot results
set(0,'DefaultLineLineWidth',2,...
    'DefaultLineMarkerSize',8, ...
    'DefaultAxesLineWidth',2, ...
    'DefaultAxesFontSize',14,...
    'DefaultAxesFontWeight','Bold');


% Now plot the estimates of the coordinates to see how well they track the
% actual coordinates figure(20) produces Figure 8.4 in the text book.
figure(20)
clf
subplot('Position',[0.1 0.06 0.85 0.17])
plot(t(thalf+1:end), xyest(:,2),'Color',[0.5 0.5 0.5],'LineWidth',3)
hold on
plot(t(thalf+1:end), position(thalf+1:end,2),'k')
%title('Tracking of y-coordinate')
legend('Est.','Act.')
ylabel('Y-Coordinate')
axis([900 1800 0 100])
xlabel('Time (sec)')

subplot('Position',[0.1 0.3 0.85 0.17])
plot(t(thalf+1:end), xyest(:,1),'Color',[0.5 0.5 0.5],'LineWidth',3)
hold on
plot(t(thalf+1:end), position(thalf+1:end,1),'k')
title('Tracking of position')
legend('Est.','Act.')
ylabel('X-coordinate')
axis([900 1800 0 100])

% Next plot the place fields again for the figure in the book
for cell = 1:4
    
    xloc = 0.5*mod(cell+1,2) + 0.1;
    yloc = 1.06 - 0.25*floor((cell+1)/2);
    subplot('Position',[xloc yloc 0.4 0.16])
    imagesc(squeeze(place_fields(:,:,cell)));
    colorbar
    colormap(gray)
    colormap(flipud(colormap));  % Inverts the gray scale to white=low, black=high
    set(gca,'YDir','Normal')
    set(gca,'XTick',[0 50 100])
    set(gca,'YTick',[0 50 100])
    
    title(strcat('Cell ',{' '},num2str(cell)))
    
    xlabel('X-coordinate')
    ylabel('Y-coordinate')
    
end
    
% Finally label the panels in the figure
annotation('textbox',[0.00 0.99 0.02 0.02],'LineStyle','none', ...
    'FontSize',16,'FontWeight','Bold','String','A1')
annotation('textbox',[0.50 0.99 0.02 0.02],'LineStyle','none', ...
    'FontSize',16,'FontWeight','Bold','String','A2')
annotation('textbox',[0.00 0.74 0.02 0.02],'LineStyle','none', ...
    'FontSize',16,'FontWeight','Bold','String','A3')
annotation('textbox',[0.50 0.74 0.02 0.02],'LineStyle','none', ...
    'FontSize',16,'FontWeight','Bold','String','A4')
annotation('textbox',[0.00 0.49 0.02 0.02],'LineStyle','none', ...
    'FontSize',16,'FontWeight','Bold','String','B1')
annotation('textbox',[0.00 0.26 0.02 0.02],'LineStyle','none', ...
    'FontSize',16,'FontWeight','Bold','String','B2')
 