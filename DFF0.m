function DFF0(file,sheet, varargin)
%% Load the data

clear all;
clc;

[filename, pathname] = uigetfile; % open the folder in current directory, you have to input the xls file

data = xlsread(filename,1); 
data = double(data);

[sy, sx] = size(data); 

 baseAvg = zeros(1,sx); 
    
    for i=1:sx %for each column 

       baseAvg(i) = prctile(data(data(:, i) >0 , i), 15); 
       %for all mean gray values of each column compute the baseAvg (F0) as the 15th percentile avoiding 0.
       
    end

for i=1:sx
    data(:,i) = (data(:,i) - baseAvg(i)) / baseAvg(i); %for each column compute the DF/F0
end

xlswrite(fullfile (pathname, filename),data,'fluorescencetraces'); % create a new sheet, named fluorescencetraces with DF/F0