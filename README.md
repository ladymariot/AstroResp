# AstroResp
AstroResp code is a custom made code to analyse Ca2+ recordings from astrocytes.

#AstroRespCode: INSTRUCTIONS FOR A TYPICAL ASTROCYTIC Ca2+ PEAK ANALYSIS SESSION.

# 1. SYSTEM REQUIREMENTS

This code was written in MATLAB, and it runs on the Windows and MAC operating systems. The following MATLAB Versions have been tested: R2015a, R2018a, R2019b.

# 2. INSTALLATION GUIDE

Simply drag and drop the AstroRespCode folder in your desired location. This folder contains the three .m files: DFF0, AstroResp, Database, Astro1 folder containing the xls file to be analyzed as DEMO and the related AstroResp_Outputfiles folder. 

Run the MATLAB software and then on the ëHomeí tab set the right path (from the set path button) linked to the AstroRespCode folder where you will have the necessary scripts (DFF0, AstroResp, Database). 

Firstly, the current folder should be the AstroRespCode folder. Doubleclick on the Database.m file to open it in the Editor tab. 
Secondly, set as current folder the Astro1 folder. 


# 3. INTRODUCTION

AstroRespCode is a custom made code to analyze huge amount of Ca2+ traces and to homogenize as much as possible the variability between ROIs.
It is useful to:

1) Compile the Database.m file as a real database of all your astrocytes to analyze. 

In the %%Dataset%% section set the directory in which the astrocyte folders are stored.

In the %%General Database%% section you can list all your astrocytes. Each astrocyte will have its own number. 
In the Database.m file now you will find two astrocytes listed as astro{1} and astro{2}. 
For each astrocytes you can analyze different experimental conditions. 
As example astro{1} as a basal condition (bsl), condition 1 (cond1) and condition 2 (cond2). It is possible to add more conditions. 
The exact name of the xls has to be written in '' without the extension (.xls), as in the case of MasterFile. 
The directory in which the xls are stored has to be added in 'folder', in this case the folder will be ë\Astro1í. 
Finally, the frame rate acquisition has to be specified in Hz.

In the %%Analyzed all exp for specified astro%% section input the number corresponding to the astrocyte to be analyzed. It could be [ 1] if just one astrocyte has to be analyzed or [ 1, 2, 3, Ö] for more astrocytes per session. In 'stim' put the name of the condition to be analyzed, in this case is only ëbslí, but you can list all the conditions you need. For more condition insert all the condition name as written in the %general database% section separated by a comma. By running the %%Analyze all exp for specified astros%% you will recall the DFF0.m and the AstroResp.m to start the computation.


a) DFF0.m adds a spreadsheet called ëfluorescencetracesí on the original xls file with all the normalized Ca2+ traces. Every ROI will correspond to a column. The F0 is calculated as the 15th percentile of the full trace excluding the values equal to 0. If your data requires a different percentile, just change the value in line 18.

b) AstroResp.m finds significant Ca2+ peaks and allows to:
- compute the amplitude and the dynamic associated with each peak. (Section %%Find the significant peak%%)
- compute the frequency per ROIs and the raster plot. (Section %%Find the significant peak%%)
- inspect the data visually and discard the noisy ROIs.
This section allows to visually inspect each trace to decide whether to consider the ROI as active or discard it because it was too noisy. This section outputs the variable 'decision', which has an 'a' or 'd' in the nth entry, depending on whether the nth astroROI was accepted or discarded. It also prints on the command window the instructions for the selection.

If you have more conditions, once finished with the first it will automatically pass to the next one.

# 4. OUTCOMES

At the end you will obtain a new xls file called ëAstroResp_nameoftheoriginalfileí in this case ëAstroResp_masterfileí that will be saved in the folder of the corresponding original .xls file in this case the Astro1 folder. This file contains:

Spreadsheet2:
1- First column will show the number of Ca2+ peaks for each accepted ROI leaving a white space for the ROIs discarded
2- Second column will show the mean amplitude of the Ca2+ peaks of each accepted ROI leaving a white space for the ROIs discarded
3- Third column will show the frequency/min of the Ca2+ peaks of each accepted ROI leaving a white space for the ROIs discarded
4- Fourth column will show the width of the Ca2+ peaks of each accepted ROI leaving a white space for the ROIs discarded
5- Fifth column will show the integers of the Ca2+ peaks of all ROI
6- Sixth column will show the number of accepted ROIs
7- Seventh column will show the number of discarded ROIs
8- Eighth column will show the total acquisition time in seconds
9- Ninth column will show the frequency/min of the Ca2+ peaks for all ROIs
10- Tenth column will show the percentage of active ROIs

Spreadsheet3: it reports the average Ca2+ dynamic snippets for each ROI and each column correspond to the values obtained from a single ROI

Spreadsheet4: it reports the time of each Ca2+ peak for all the ROIs and each column correspond to one ROI

You will be also able to visualize the data printed in a PDF file named in this case ëAstroRespFig_masterfileí containing: 
- Top left: average of the Ca2+ dynamic snippets with the relative error
- Bottom left: Ca2+ dynamic snippets aligned to their onset with the DF/F colour coded
- Top right: the raster plot with the Ca2+ peak/time
- Bottom right: the PSTH relative to the raster plot



HOW TO RUN THE CODE
Run the code by pressing cmd+enter for mac or ctrl+enter for PC, in the following sequence:

- %%Dataset%%
- %%General Database%%  
- %%Analised all exp for specified astro%%


The run time for the demo is approximately 10 minutes.


In the AstroRespCode folder you will find a database.m file already compiled for the analysis of the master_file.xls, that you will find in the Astro1 subfolder. 
