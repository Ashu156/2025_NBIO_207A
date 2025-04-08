clc;
clear all;
%close all;
%%
%-----------load the data----------%
load('Spiketrains_running.mat')
%%
%-----------CCG params----------%
% for theta CCG
bin = 0.01; % 10 ms
tmax = 0.5; % +/- 500ms for corrln
sw1 = bin*2; % for smoothing corrln. 
% for SWR CCG
bin_swr = 0.002; % 2 ms
sw1_swr = 0.01; % 10 ms smoothing
%%
%----------- CCG----------%
[timebase_theta, rawcorr_theta, corr_sm_theta] = spiketrainxcorr(spikes1,spikes2,bin,tmax,sw1);
set(0,'defaultaxesfontsize',16);
figure('color','w')
plot(timebase_theta.*1000,corr_sm_theta,'linewidth',2)
hold on
plot([0,0],[0,0.35],'k--')
xlabel('Time lag (ms)')
ylabel('Correlation')
title('Crosscorrelogram during active running')
box off
%%

