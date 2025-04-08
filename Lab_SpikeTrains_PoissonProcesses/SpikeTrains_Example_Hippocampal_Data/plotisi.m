function ISI=plotisi(spikes)

spktimes = spikes*1e3; % Convert from seconds to ms
ISI=diff(spktimes);
edges = [0:0.5:100]; % 0 to 100/200 ms; 0.5 ms bins

%%-- define an interval which could possibly fall within the 
%%-- refractory period of a neuron; inter-event intervals that are 
%%-- less than CRITERION invite scrutiny
CRITERION = 2;

counts = histc(ISI,edges);
counts_below = histc(ISI(ISI < CRITERION),edges);

figure; hold on;

%%-- stacked histogram
for i = 1:(length(edges)-1)
    patch([edges(i) edges(i+1) edges(i+1) edges(i)], ...
      [0 0 counts_below(i) counts_below(i)],'r');
    patch([edges(i) edges(i+1) edges(i+1) edges(i)], ...
      [cou
      nts_below(i) counts_below(i) counts(i) counts(i)],'k');
end
xlabel('Inter-spike interval (ms)');
ylabel('Counts');


% --- log plot ----
xtickloc = 0:1:3;
logISI = log10(diff(spktimes));
edges = xtickloc(1):0.05:xtickloc(end);  

figure; hold on;
a = axes();
%set(gca,'XTick',[],'XTickLabel',[]); set(gca,'YTick',[],'YTickLabel',[]);
%%-- stacked histogram
for i = 1:(length(edges)-1)
    patch([edges(i) edges(i+1) edges(i+1) edges(i)], ...
      [0 0 counts_below(i) counts_below(i)],'r');
    patch([edges(i) edges(i+1) edges(i+1) edges(i)], ...
      [counts_below(i) counts_below(i) counts(i) counts(i)],'k');
end
set(a,'XLim',[xtickloc(1) xtickloc(end)],'XTick',xtickloc, ... 
 'XTickLabel',arrayfun(@num2str,10.^xtickloc,'UniformOutput',false));
xlabel('inter-event interval (ms)');
ylabel('counts');