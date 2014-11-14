
% script to rename raw nifti files for experiment SA2

clear all
close all

<<<<<<< HEAD
subj = '15';
cni_id = '8301'; % (first 4 digits of file names)
=======
subj = '27';
cni_id = '8259'; % (first 4 digits of file names)
>>>>>>> 2e11a847000a60847fd76db98d4f604995aa8b20


p = getSA2Paths(subj);

%% do it


cd(p.raw)

%% use physio reg files to determine functional runs

phys = dir([cni_id '*physio.tgz']);
phys2 = dir([cni_id '*physio_regressors.csv.gz']);


if numel(phys)~=6 || numel(phys2)~=6
    disp('detected too few or too many functional scan runs, or maybe filenames were already changed');
end

for i=1:numel(phys)
    j = regexp(phys(i).name,'\d*','Match');
    scan_nums(i) = str2num(j{2});
    f(i)= dir([cni_id '_' num2str(scan_nums(i)) '_1.nii.gz']);
end
[scan_nums,idx]=sort(scan_nums);
f=f(idx); phys=phys(idx);  phys2=phys2(idx);

% display found scans
fprintf('\n functional runs detected (in order): \n\n')
<<<<<<< HEAD
for i=1:numel(phys)
=======
for i=1:6
>>>>>>> 2e11a847000a60847fd76db98d4f604995aa8b20
    disp([f(i).name '  >  run' num2str(i) '.nii.gz']);
end

% continue? 
c= input('\n\ncontinue (y/n)? ','s');

if ~strcmpi(c,'y')
    error('stopped script based on user input')
else
<<<<<<< HEAD
    for i=1:numel(phys)
=======
    for i=1:6
>>>>>>> 2e11a847000a60847fd76db98d4f604995aa8b20
        movefile(f(i).name,['run' num2str(i) '.nii.gz']);
        movefile(phys(i).name,['physio_run' num2str(i) '.tgz']);
        movefile(phys2(i).name,['physio_regs_run' num2str(i) '.csv.gz']);
    end
end


%% now look for fieldmap runs 



fm=dir('*B0.nii.gz');
if numel(fm)>=1
    disp(['detected ' num2str(numel(fm)) ' fieldmap files']);
end

for i=1:numel(fm)
    j = regexp(fm(i).name,'\d*','Match');
    fm_nums(i) = str2num(j{2});
    fm2(i)= dir([cni_id '_' num2str(fm_nums(i)) '_1.nii.gz']);
end
[fm_nums,idx]=sort(fm_nums);
fm=fm(idx); fm2=fm2(idx);

% figure out when fieldmap scans were performed in relation to func scans
for i=1:numel(fm)
    fm_scan_idx = find(fm_nums(i)<scan_nums,1,'first');
    out_fm_strs{i} = ['fmap' fm_scan_idx '_B0.nii.gz'];
    out_fm_strs2{i} = ['fmap' fm_scan_idx '.nii.gz'];
end

fprintf('\n these field maps scans detected (in order), to be renamed to the following: \n\n');

for i=1:numel(fm)
    disp([fm(i).name '  >  ' out_fm_strs{i}]);
    disp([fm2(i).name '  >  ' out_fm_strs2{i}]);
end

c= input('\n\ncontinue (y/n)? ','s');

if ~strcmpi(c,'y')
    error('stopped script based on user input')
else
    for i=1:numel(fm)
        movefile(fm(i).name,out_fm_strs{i});
        movefile(fm2(i).name,out_fm_strs2{i});
    end
end


%% now look for dti runs

dw=dir('*bvec');
if ~isempty(dw)
    disp('detected dw files');
end

