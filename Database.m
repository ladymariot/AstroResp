%% Dataset
momDirGCaMP = 'C:\Users\ASUS\Documents\LAB\AstroAnalysis\AstroRespCode'; %update current directory 

%% General Database
astro{1}.bsl= 'filename'; %exact name of excel file
astro{1}.cond1= 'XLScond1'; 
astro{1}.cond2= 'XLScond2'; %add more conditions if necessary
astro{1}.folder = '\Astro1'; %folder containing the excel files of astro{1}
astro{1}.Fq = 1.53; %framerate in Hz

astro{2}.bsl= 'filename'; %exact name of excel file
astro{2}.cond1= 'XLScond1'; 
astro{2}.cond2= 'XLScond2'; %add more conditions if necessary
astro{2}.folder = '\folderAstro2'; %folder containing the excel file of astro{2}
astro{2}.Fq = 1.53; %framerate in Hz

%% Analyze all exp for specified astros

toAnalyze = [1]; %input the number of the astrocyte that you want to analyze; 
                 %if you want to analyze more astrocytes look at the example below

% toAnalyze = [1,2,4];                  

stim = {'bsl'}; %put the name of the condition you want to analyze
                 %if you want to analyze more conditions look at the example below

% stim = {'bsl', 'cond1', 'cond2'}; 
                 
for ia = toAnalyze 
    for istim = 1:numel(stim)
        if ~isempty(astro{ia}.(stim{istim}))
                    DFF0(astro{ia}.(stim{istim}), fullfile(momDirGCaMP, astro{ia}.folder), astro{ia}.Fq);
                    AstroResp(astro{ia}.(stim{istim}), fullfile(momDirGCaMP, astro{ia}.folder), astro{ia}.Fq);
            drawnow;
            pause;     
        end
    end
end