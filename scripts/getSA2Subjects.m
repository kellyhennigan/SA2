function [subs,cb] = getSA2Subjects()

% subject strings to include in data analysis
subs = {'9','10','11','12','14','15','16','17','18','19','20',...
    '21','23','24','25','26','27','28','29'};
   
% context order code corresponding to the subjects above 
% (1=baseline first, 2=stress first)
cb = [ 2 2 2 2 1 1 2 2 1 2 1 1 2 2 1 1 1 1 1]; 