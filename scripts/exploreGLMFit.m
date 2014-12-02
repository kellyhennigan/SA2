
% get design matrix
cd '/Volumes/Mac OS X Install ESD/SA2/data/23/design_mats'
load('glm_can_runALL.mat')

% get data
cd ../func_proc/
Y = dlmread('ts_roi1');


% plot raw data and baseline-corrected data
figure
subplot(2,1,1)
plot(Y(1:326))
subplot(2,1,2)
plot(stats.err_ts(1:326))

stats = glm_fmri_fit(stats.err_ts,X(:,25:end),regIdx(25:end));