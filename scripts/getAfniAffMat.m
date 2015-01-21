function params = getAfniAffMat(fileName)
% --------------------------------
% usage: function to import the 1d affine matrix params generated using the
% 3dvolreg -1Dmatrix_save option
% 
% INPUT:
%   fileName - string specifyingt the text file that has the affine matrix
%   params

% 
% OUTPUT:
%   params - N x 12 matrix w/each row giving the affine matrix for
%            transforming the ref vol to the input to 3dvolreg
% 
% NOTES:
% 
% author: Kelly, kelhennigan@gmail.com, 17-Jan-2015

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Format string for each line of text

formatSpec = '%13f%14f%14f%14f%14f%14f%14f%14f%14f%14f%14f%f%[^\n\r]';


%% Open the text file.

fileID = fopen(fileName,'r');


%% Read columns of data according to format string.

dataArray = textscan(fileID, formatSpec, 'Delimiter', '', 'WhiteSpace', '', 'HeaderLines' ,1, 'ReturnOnError', false);

%% Close the text file.

fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Create output variable

params = [dataArray{1:12}];

