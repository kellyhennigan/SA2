function [subjs,CB] = getSA2Subjects(subgroup)

% notes: 
% last 2 scan runs from subj 28 weren't saved 
% subjects 21 and 29 didn't learn

% 9 - didn't get >55% correct for gains and/or losses
% 10 - good; scaling data now, mask is made
% 11 - good (on mt-tam); scaling data now 
% 12 - didn't get >55% correct for gains and/or losses
% 14 - good (on mt-tam)
% 15 - good (on mt-tam)
% 16 - didn't get >55% correct for gains and/or losses; fell asleep a
       % little, crazy head movement
% 17 - fmri data missing from later runs
% 18 - good, on xhd
% 19 - good, on xhd
% 20 - didn't get >55% correct for gains and/or losses
% 21 - didn't get >55% correct for gains and/or losses
% 23 - ready for glm fit
% 24 - good, on xhd almost ready for glm, just needs gzip on func data niis
% 25 - good, on xhd, shuold be good in some minutes 
% 26 - preprocessing messed up for runs 3-5; on mt-tam
% 27 - good, on mt-tam
% 28 - fmri data missing from later runs
% 29 - didn't learn but processing anyway 
% 


% all subjects for which there is a full set of behavioral data
all_subjs = {'9','10','11','12','14','15','16','17','18','19','20','21',...
    '23','24','25','26','27','28','29'};



% this only includes subjects that got >55% of gain & loss trials 'correct'
% subjects with good behavior (excluding subjects 21 & 29 bc they didn't learn but
% including subjects that may be excluded bc of bad MR data
RL_subjs = {'10','11','14','15','17','18','19',...
    '23','24','25','26','27','28'};


% only subjects for which we have a full functional data set 
fmri_subjs = {'9','10','11','12','14','15','16','18','19','20','21',...
    '23','24','25','26','27','29'};


% only subjects for which we have a full functional data set 
best_subjs = {'10','11','14','15','18','19','23','24','25','26','27'};



if notDefined('subgroup')
    subgroup = 'all';
end

if strcmpi(subgroup,'RL')
    subjs = RL_subjs;
elseif strcmp(subgroup,'fmri')
    subjs = fmri_subjs;
elseif strcmp(subgroup,'best')
    subjs = best_subjs;
elseif any(strcmp(num2str(subgroup),all_subjs)) % allow input of a subj num to get the cb code
    subjs = all_subjs(find(strcmpi(num2str(subgroup),all_subjs))); 
else
  subjs = all_subjs;
end


%% get the corresponding context code for the subject array 

subjCBLookup = [
9     2
10    2
11    2
12    2
14    1
15    1
16    2
17    2
18    1
19    2
20    1
21    1
23    2
24    2
25    1
26    1
27    1
28    1
29    1];

for i=1:numel(subjs)
    CB(i,1) = subjCBLookup(subjCBLookup==str2double(subjs{i}),2);
end