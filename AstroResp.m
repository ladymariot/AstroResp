function AstroResp(filename, folder, Fq)
%% Load the data
cd(folder);

data = xlsread(filename, 'fluorescencetraces');

[nT, nA] = size(data); %matrix with nT = nframes nA= nROI

tvec = (1:nT)/Fq; 
%% set important parameters

trsh = 2; %trsh*sd will be the treshold for peak significance
dyntrsh = 4; %dyntrsh*sd will be the treshold for dynamics amplitude acceptance

%% compute sd for significance threshold

sd = std(data,[], 1); %this is the full trace std of each astro


newsd = zeros(size(sd)); 

for ia = 1:nA
    
     newsd(ia) = std(data(data(:, ia) <2*sd(ia) & data(:, ia) > -2*sd(ia), ia)); %this is the std of the part of the data that are under 2*sd
    
end


%% find the the significant peaks, and measure the associated dynamics

baseAvg = zeros(1,nA); %matrix created in order to compute the baseline of the entire trace. 

    for ia=1:nA
        baseAvg(ia) = prctile(data(data(:, ia) >0 , ia), 20);   
    end
    
  
for ia = 1: nA
    
    [pks{ia}, locs{ia}, w{ia}, p{ia}] = findpeaks(data(:, ia), 'MinPeakHeight', trsh*newsd(ia), 'MinPeakDistance', 15); %finds the peaks above trsh*newsd
    truepk{ia} = []; 
    truew{ia} = []; 
    onset{ia} = [];
    amplitude{ia} = []; 
    lcbsl{ia} = []; 
    badpk{ia} = []; 
    lcbslbad{ia} = []; 
    timepeak{ia} = []; 
    
    if ~isempty(pks{ia})
      
        lastpk = 1;
       
        for ipk = 1: numel(pks{ia})
            
            for lastpk = 1 
            dyn{ia}(ipk) = pks{ia}(ipk) - baseAvg(ia); 
            end 
            
            if lastpk > 1
                dyn{ia}(ipk) = pks{ia}(ipk) - prctile(data(lastpk:locs{ia}(ipk), ia), 20);
            end
            %compute the amplitude of the
            % dynamic associated with each peak. Similar approach to
            % Volterra's paper. The difference is that we consider only the
            % peaks that were > 2*sd (see before). Also, to measure the
            % amplitude of the dynamic we consider the 20th percentile of
            % the signal in the interval between the current peak adn the
            % previous one. The assumption here is that calcium dynamics in the
            % astrocyte are additive. We take the 20th percentile hoping
            % that is more robust to noise than the minimum.
            
            if dyn{ia}(ipk) < dyntrsh*newsd(ia)                    
            badpk{ia} = [badpk{ia} , locs{ia}(ipk)];
            lc0bad{ia}(ipk) = prctile(data(lastpk:locs{ia}(ipk), ia), 20);
            lcbslbad{ia} = [lc0bad{ia}(ipk), lcbslbad{ia}];  
            end
            
            if dyn{ia}(ipk) > dyntrsh*newsd(ia) % we keep as significant events only
                %the peaks associated with dynamics that are > dyntrsh*newsd
                truepk{ia} = [truepk{ia} , locs{ia}(ipk)]; % this is the position of the peak 
                on = data(lastpk:locs{ia}(ipk), ia)- prctile(data(lastpk:locs{ia}(ipk), ia), 30);
                onset{ia} = [onset{ia}, lastpk + find(on <1*newsd(ia), 1, 'last')];%this is raising time of the peak, the last time point when F was below 1*sd
                truew{ia} = [truew{ia} , w{ia}(ipk)];
                amplitude{ia} = [amplitude{ia}, dyn{ia}(ipk)]; % this is the amplitude of the dynamic
                lc0{ia}(ipk) = prctile(data(lastpk:locs{ia}(ipk), ia), 20); 
                lcbsl{ia} = [lc0{ia}(ipk), lcbsl{ia}]; 
                lastpk = locs{ia}(ipk);                 
            end
            
        end
    end 
    freqResp(ia) = numel(amplitude{ia})/max(tvec);
    
end  

    MW = NaN(20,nA);
    TP = NaN(20,nA);
    t = 0;
    l= 0;
    
    for c = 1:nA
        l = truepk{1, c};
        TP(1:(length(l)), c) = (truepk{1,c})/Fq;
    end 
    
    for x = 1:nA
        t = truew{1, x};
        MW(1:(length(t)), x)= truew{1,x};
    end
   
    
%% inspect the data and discard noisy ROI
%visually inspect each trace and the detected peaks to decided wether to
%keep the ROI or discard it because it was too noisy to start with. This
%section outputs the variable 'decision', which has an 'a' or 'd' iin the
%nth entry, depending on wether the nth astroROI was accepted or discarded.
%Prints on the command window the instructions for the selection.

selection = figure;
ia = 1;
decision = [];

while ia <= nA
    clf;
    plot(tvec, data(:,ia), 'k');
    hold on
    plot([0, max(tvec)], [2*newsd(ia), 2*newsd(ia)], '--g')
    plot(truepk{ia}/Fq,data (truepk{ia}, ia), 'xr'); 
    plot(badpk{ia}/Fq, lcbslbad{ia}, 'og'); 
    plot(truepk{ia}/Fq, lcbsl{ia}, 'ob');
    
   xlim([1, nT/Fq]);
    xlabel ('Time (s)');
    ylabel('dF/Fo')
    string = ['astroROI n %i of %i of exp %s:\n Inspect the trace and check:', ...
        '\n u to undo the last choice',...
        '\n a to accept the astroROI',...
        '\n d to discard the astroROI ',...
        '\n q to end here - exit analysis \n'];
    fprintf(string, ia, nA, filename);
    waitforbuttonpress;
    c = get(gcf, 'CurrentCharacter');
    switch c
        case 'q' % quit
            return;
        case 'a' % accept trace
            decision = [decision , 'a'];
            ia = ia +1;           
        case 'd' % discard trace
            decision = [decision, 'd'];
            ia = ia +1;
        case 'u' %undo last choice
            if ia >1
                ia = ia -1;
                decision = decision(1: end-1);
            else
                ia = 1;
                sprintf('Hai appena iniziato stupida!')
            end           
    end
end

close(selection);



%% cut responses snippets
% Cut a snippet of each dynamic and collect in a matrix for each astroROI
%Then compute the average dynamic per astroROI and the global average and
%standard error. 

padS = NaN(round(5*Fq), nA); 
padE = NaN(round(20*Fq), nA); 
padData = [padS; data; padE]; 
                               
                               
padPeak = [padS;padE]; 
Resp = cell(1,nA);
GGG = cell(1,nA);

for ia = 1: numel(decision); 
    if decision(ia) == 'a';
        GGG{ia} = truepk{ia}';
        padonset{ia} = onset{ia} + round(5*Fq);
        for iSp = 1: numel(onset{ia})
            first = padonset{ia}(iSp) - round(5*Fq) +1;
            last = padonset{ia}(iSp) + round(20*Fq);
            Resp{ia}(:,iSp)= padData(first:last, ia)- nanmean(padData(first:(first+round(5*Fq)-1), ia));             
        end  
    end
end
peakT = [];

allResp = [];
roiResp = [];
goodAstro = 0;

for ia = 1:nA %from 1 to number of ROI
    if ~isempty(Resp{ia}) 
        goodAstro = goodAstro +1; 
        roiResp(:, goodAstro) = nanmean(Resp{ia},2);
        allResp = [allResp, Resp{ia}]; 
    end    
end


aveResp = nanmean(roiResp, 2); %average response across all goodAstro
seResp = nanstd(roiResp, [], 2)/sqrt(goodAstro); %standard error of average response

%% compute PSTH
poolT = [];

for ia = 1: numel(decision);
    if decision(ia) == 'a'
        poolT = [poolT, onset{ia}];
    end
end
poolT = poolT/Fq; %pooled times of responses across all good astro
bins = 0:20:(nT/Fq); %time bins for psth



%% PLOT
if ~isempty(roiResp)

summary = figure;
tt = (1: size(aveResp,1))/Fq;  %make time vecor for snippets

subplot(2,2,1)
shadePlot(tt, aveResp,seResp, 'b') % plot average response +- standard error
xlim([min(tt), max(tt)])
ylabel('dF/F')
subplot(2,2,3)
imagesc(tt, [], allResp') % color plot of all responses from all goodAstro
caxis([-1 prctile(allResp(:), 90)]);
colormap('jet')
colorbar
xlabel('Time (s)')
ylabel('event #')
formatAxes
subplot(2,2,2)
for ia = 1: nA
    for ipk = 1: numel(onset{ia})
        if decision(ia) == 'a'
        plot([onset{ia}(ipk), onset{ia}(ipk)]/Fq, [ia-1, ia], 'k', 'LineWidth', 2); hold on
        end
        % raster plot
    end
end
ylim([0, nA+1]);
xlim([0, nT/Fq])
ylabel('astroROI #')
formatAxes
subplot(2,2,4)
histogram(poolT, bins) % psth of responses
xlim([0, nT/Fq])
xlabel('Time (s)')
ylabel('Event #')
formatAxes

set(summary, 'color', 'white', 'renderer', 'painters')
print(['astroRespFig_', filename], '-dpdf')

end

%% SAVE
% save a .mat file with the analysis
save(fullfile(folder, ['astroResp_', filename]), 'data', 'tvec',  'truepk', 'onset',...
    'amplitude', 'locs', 'decision', 'poolT', 'padData', 'allResp', 'Resp', ...
    'roiResp', 'aveResp', 'seResp', 'TP');

%% write a xls or csv files

stats = NaN(nA, 6);
for ia = 1:nA  
   for ia = 1: numel(decision);
    if decision(ia) == 'a';
        columns = zeros(1,nA); %matrix created in order to convert data pool in a vector... by this way is possible to use "trapz" function to calculate integral
    stats(ia, 1) = numel(amplitude{ia});
    stats(ia, 2) = mean(amplitude{ia});
    stats(ia, 3) = numel(amplitude{ia})/max(tvec);
    stats(ia, 4) = mean(w{ia});
    for ia=1:nA  
        columns = truepk{ia};
        integrale(ia) = trapz(columns); 
    end 
    end
   end
end

stats(:, 5) = integrale;
stats(1, 6) = sum(decision == 'a');
stats(1, 7) = sum(decision == 'd');
stats(1, 8) = max(tvec);
stats(:, 9) = freqResp; 
stats(1, 10) = [sum(decision == 'a')/nA]*100; 

if ispc
    xlswrite(fullfile (folder,['astroResp_', filename]),stats,'NP_Amp_Freq_w_INT_aR_dR_T_0_%'); % save stats
    xlswrite(fullfile (folder,['astroResp_', filename]),roiResp,'aveResp'); % save average Resp of goodAstro
    xlswrite(fullfile (folder,['astroResp_', filename]),TP,'timepeaks'); %save time true peaks of each ROI
else
    csvwrite(fullfile (folder,['astroResp_Amp_Int_Freq_Time_respROI_silentROI', filename]),stats); % save stats
    csvwrite(fullfile (folder,['astroResp_aveResp', filename]),roiResp); % save average Resp of goodAstro
    csvwrite(fullfile (folder,['astroResp_', filename]),TP);
end