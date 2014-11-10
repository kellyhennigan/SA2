% check out multiplex data

cd '/Users/Kelly/SA2/data/pilot'

figuredir = '/Users/Kelly/SA2/figures';

% * note: both of these runs were 4min and 12 sec
mux1 = readFileNifti('mux1_MID_run2.nii.gz');
% mux3 = readFileNifti('mux3_MID_run1.nii.gz');

mux1dim = size(mux1.data);
% mux3dim = size(mux3.data);

coords = [79,50,12];
vox1=squeeze(mux1.data(coords(1),coords(2),coords(3),:));
vox3=squeeze(mux3.data(coords(1),coords(2),coords(3),:));

figure
plot(vox3,'r')
hold on
plot(vox1,'b')

%% slice time correction

% % convert sliceorder word cases
% if ischar(episliceorder)
%   switch episliceorder
%   case 'sequential'
%     episliceorder = 1:epidim;
%   case 'interleaved'
%     episliceorder = [1:2:epidim 2:2:epidim];
%   case 'interleavedalt'
%     if mod(epidim,2)==0
%       episliceorder = [2:2:epidim 1:2:epidim];
%     else
%       episliceorder = [1:2:epidim 2:2:epidim];
%     end
%   otherwise
%     error;
%   end
% end
% 
% % slice time correct [NOTE: we may have to do in a for loop to minimize memory usage]
% if ~isempty(episliceorder)
%   fprintf('correcting for differences in slice acquisition times...');
%   epis = cellfun(@(x,y) sincshift(x,repmat(reshape((1-y)/max(y),1,1,[]),[size(x,1) size(x,2)]),4), ...
%                  epis,repmat({calcposition(episliceorder,1:max(episliceorder))},[1 length(epis)]),'UniformOutput',0);
%   fprintf('done.\n');
% end
% 
%% compute temporal SNR

% compute temporal SNR
  % this is a cell vector of 3D volumes.  values are percentages representing the median frame-to-frame difference
  % in units of percent signal.  (if the mean intensity is negative, the percent signal doesn't make sense, so
  % we set the final result to NaN.)  [if not enough volumes, some warnings will be reported.]
fprintf('computing temporal SNR...');

temporalsnr_mux3 = cellfun(@computetemporalsnr,{mux3.data},'UniformOutput',0);
temporalsnr_mux1 = cellfun(@computetemporalsnr,{mux1.data},'UniformOutput',0);


fprintf('done.\n');

 
% write out EPI inspections
% if wantfigs
  fprintf('writing out various EPI inspections...');

  % first and last of each run
%   viewmovie(catcell(4,cellfun(@(x) double(x(:,:,:,1)),{mux3.data},'UniformOutput',0)),sprintf('%s/EPIoriginal/image_mux3%%04da',figuredir));
%   viewmovie(catcell(4,cellfun(@(x) double(x(:,:,:,end)),{mux3.data},'UniformOutput',0)),sprintf('%s/EPIoriginal/image_mux3%%04db',figuredir));
% 
%   viewmovie(catcell(4,cellfun(@(x) double(x(:,:,:,1)),{mux1.data},'UniformOutput',0)),sprintf('%s/EPIoriginal/image_mux1%%04da',figuredir));
%   viewmovie(catcell(4,cellfun(@(x) double(x(:,:,:,end)),{mux1.data},'UniformOutput',0)),sprintf('%s/EPIoriginal/image_mux1%%04db',figuredir));
%   

% movie of first run
  viewmovie(double(mux3.data(:,:,:,1:min(30,end))),sprintf('%s/MOVIEoriginal/image_mux3%%04d',figuredir));
  viewmovie(double(mux1.data(:,:,:,1:min(30,end))),sprintf('%s/MOVIEoriginal/image_mux1%%04d',figuredir));

  % temporal SNR for each run
%   for p=1:length(temporalsnr_mux3)
    imwrite(uint8(255*makeimagestack(tsnrmx-temporalsnr_mux3{p},[0 tsnrmx])),jet(256),sprintf('%s/temporalsnr_mux3%02d.png',figuredir,p));
    imwrite(uint8(255*makeimagestack(tsnrmx-temporalsnr_mux1{p},[0 tsnrmx])),jet(256),sprintf('%s/temporalsnr_mux1%02d.png',figuredir,p));
%   end

  fprintf('done.\n');
end



%% motion correction