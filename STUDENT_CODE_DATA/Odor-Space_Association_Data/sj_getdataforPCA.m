
% Get Data for PCA analyses
% -------------------------


animals = {'CS31','CS33','CS34','CS35','CS39','CS41','CS42','CS44'};
regions = {'CA1','PFC'};

%region = 'CA1';  animal = 'CS34';  animno = 3; day = 4;
region = 'PFC'; animal = 'CS42';  animno = 7; day = 6;

dataDir = '/Users/shantanu/Dropbox/Mac (2)/Documents/GitHub/2025_NBIO_207A/STUDENT_CODE_DATA/Odor-Space_Association_Data/';
figDir = '/Users/shantanu/Dropbox/Mac (2)/Documents/GitHub/2025_NBIO_207A/STUDENT_CODE_DATA/Odor-Space_Association_Data/sj_Figures'
%dataDir = '/Users/Shantanu/data25/OLF_CS/Data/';
%figdir = '/Users/Shantanu/data25/OLF_CS/Data/sj_Figures';

animalDir = [dataDir,animal,'_direct/'];
load([animalDir,animal,'cellinfo.mat'])
daystr = getTwoDigitNumber(day);
load([animalDir,animal,'nosepokeWindow',daystr,'.mat'])

win = [0.2 0.8]; % Implies from -0.2 to 8
binsize=0.1;
binsize_ms=1000*binsize;
selectiveonly=0;
timeaxis = -1000*win(1):binsize_ms:1000*win(2);

%digits(16);

win1 = 0 - win(1); %make negative
winstr = [(num2str(win1*1000)),'-',num2str(win(2)*1000),'ms'];

if selectiveonly == 1
    selstr = '_selectivecells';
else
    selstr = '';
end

%% --- Calculate
disp('creating column vectors')
[leftfr, rightfr, lefttrials, righttrials, cellinds, np_left,np_right,np_all] = sj_columnVectors_day_npCells(animal, animno, day, region, win, binsize);
%[leftfr, rightfr, lefttrials, righttrials, cellinds] = cs_columnVectors(animals, region, win, binsize, selectiveonly);
%
% Get Bins
allbins = [-0.5:binsize:1.5-binsize];
goodbins = [win1:binsize:win(2)-binsize]; 
%binind = lookup(goodbins,allbins);
%numtimebins = length(goodbins);

numtimebins = length(goodbins); 


