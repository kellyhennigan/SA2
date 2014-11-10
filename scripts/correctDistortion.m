

function correctDistortion

% fieldmaps,fieldmapbrains,fieldmap_vox_sizes,fieldmapdeltate,...
%     fieldmaptimes,fieldmapunwrap,fieldmapsmoothing,figuredir)

% <fieldmaps> is a 3D volume of phase values (in [-pi,pi]) or a cell vector
%   of such volumes.

% <fieldmapbrains> is a 3D volume of magnitude brains or a cell vector
%   of such volumes.  can be {}.  should mirror <fieldmaps>.

% <fieldmap_vox_size> is a 3-element vector with the voxel size in mm
%   or a cell vector of such vectors.

% <fieldmapdeltate> is the difference in TE that was used for the fieldmap
%   or a vector of such differences.  should be in milliseconds.  can be [].
%   should mirror <fieldmaps>.  

% <fieldmapunwrap> is whether to attempt to unwrap the fieldmap. Can be 0
% or 1. Unwrapping happens using FSL's prelude function with '-s -t 0'
% options

% <fieldmapsmoothing> is a 3-element vector with the size of the
%   bandwidth in mm to use in the local linear regression or a cell vector
%   of such vectors. 

% figuredir



% calc fieldmap stuff
fmapsc = 1./(fieldmapdeltate/1000)/2;  % vector of values like 250 (meaning +/- 250 Hz)

% write out fieldmap inspections
  fprintf('writing out various fieldmap inspections...');

  % write out fieldmaps, fieldmaps brains, and histogram of fieldmap
  for p=1:length(fieldmaps)
%   p=1
    % write out fieldmap
    imwrite(uint8(255*makeimagestack(fieldmaps{p}/pi*fmapsc(p),[-1 1]*fmapsc(p))),jet(256),sprintf('%s/fieldmap%02d.png',figuredir,p));

    % write out fieldmap diff
    if p ~= length(fieldmaps)
      imwrite(uint8(255*makeimagestack(circulardiff(fieldmaps{p+1},fieldmaps{p},2*pi)/pi*fmapsc(p), ...
        fmapdiffrng)),jet(256),sprintf('%s/fieldmapdiff%02d.png',figuredir,p));
    end
  
    % write out fieldmap brain
    imwrite(uint8(255*makeimagestack(fieldmapbrains{p},1)),gray(256),sprintf('%s/fieldmapbrain%02d.png',figuredir,p));
    
    % write out fieldmap brain cropped to EPI FOV
    imwrite(uint8(255*makeimagestack(processmulti(@imresizedifferentfov,fieldmapbrains{p},fieldmap_vox_sizes{p}(1:2), ...
      epidim(1:2),episize(1:2)),1)),gray(256),sprintf('%s/fieldmapbraincropped%02d.png',figuredir,p));

    % write out fieldmap histogram
    figureprep; hold on;
    vals = prctile(fieldmaps{p}(:)/pi*fmapsc(p),[25 75]);
    hist(fieldmaps{p}(:)/pi*fmapsc(p),100);
    straightline(vals,'v','r-');
    xlabel('Fieldmap value (Hz)'); ylabel('Frequency');
    title(sprintf('Histogram of fieldmap %d; 25th and 75th percentile are %.1f Hz and %.1f Hz',p,vals(1),vals(2)));
    figurewrite('fieldmaphistogram%02d',p,[],figuredir);
  
  end

  fprintf('done.\n');

  reportmemoryandtime;

  
%%  unwrap fieldmaps
%   parfor p=1:length(fieldmaps)
  
if fieldmapunwrap
    fieldmapunwraps = {};
  fprintf('unwrapping fieldmaps...');

    
for p = 1:length(fieldmaps)
     
      % get temporary filenames
      tmp1 = tempname; tmp2 = tempname;
      
      % make a complex fieldmap and save to tmp1
      save_untouch_nii(make_ana(fieldmapbrains{p} .* exp(j*fieldmaps{p}),fieldmap_vox_sizes{p},[],32),tmp1);
      
      % use prelude to unwrap, saving to tmp2
      unix_wrapper(sprintf('prelude -c %s -o %s -s -t 0; gunzip %s.nii.gz',tmp1,tmp2,tmp2));
      
      % load in the unwrapped fieldmap
      temp = load_nii(sprintf('%s.nii',tmp2));  % OLD: temp = readFileNifti(tmp2);
      
      % convert from radians centered on 0 to actual Hz
      fieldmapunwraps{p} = double(temp.img)/pi*fmapsc;
    
    else
  
      % convert from [-pi,pi] to actual Hz
      fieldmapunwraps{p} = fieldmaps{p}/pi*fmapsc(p);
  
    end
  
  end
  fprintf('done.\n');


  reportmemoryandtime;

  %% additional inspections
  
% write out inspections of the unwrapping and additional fieldmap inspections
  fprintf('writing out inspections of the unwrapping and additional inspections...');
  
  % write inspections of unwraps
  for p=1:length(fieldmaps)
    imwrite(uint8(255*makeimagestack(fieldmapunwraps{p},[-1 1]*fmapsc)),jet(256),sprintf('%s/fieldmapunwrapped%02d.png',figuredir,p));
  end

  % write slice-mean inspections
    % this is fieldmaps x slice-mean with the (weighted) mean of each slice in the fieldmaps:  
    fmapdcs = catcell(1,cellfun(@(x,y) sum(squish(x.*abs(y),2),1) ./ sum(squish(abs(y),2),1),fieldmapunwraps,fieldmapbrains,'UniformOutput',0));
  figureprep; hold all;
  set(gca,'ColorOrder',jet(length(fieldmaps)));
  h = plot(fmapdcs');
  legend(h,mat2cellstr(1:length(fieldmaps)),'Location','NorthEastOutside');
  xlabel('Slice number'); ylabel('Weighted mean fieldmap value (Hz)');
  title('Inspection of fieldmap slice means');
  figurewrite('fieldmapslicemean',[],[],figuredir);

  fprintf('done.\n');


  reportmemoryandtime;

% use local linear regression to smooth the fieldmaps
smoothfieldmaps = cell(1,length(fieldmapunwraps));
if wantundistort && ~isequalwithequalnans(epifieldmapasst,NaN)
  fprintf('smooth the fieldmaps...');
  for p=1:length(fieldmapunwraps)
    if isnan(fieldmapsmoothing{p})
      smoothfieldmaps{p} = processmulti(@imresizedifferentfov,fieldmapunwraps{p},fieldmap_vox_size(1:2),epi_dim(1:2),vox_dim(1:2));
    else
      fsz = sizefull(fieldmaps{p},3);
      [xx,yy,zz] = ndgrid(1:fsz(1),1:fsz(2),1:fsz(3));
      [xi,yi] = calcpositiondifferentfov(fsz(1:2),fieldmap_vox_sizes{p}(1:2),epi_dim(1:2),vox_dim(1:2));
      [xxB,yyB,zzB] = ndgrid(yi,xi,1:fsz(3));
      smoothfieldmaps{p} = nanreplace(localregression3d(xx,yy,zz,fieldmapunwraps{p},xxB,yyB,zzB,[],[],fieldmapsmoothing ./ fieldmap_vox_size,fieldmapbrains{p},1),0,3);
    end
  end
  fprintf('done.\n');
end

  reportmemoryandtime;

% write out smoothed fieldmap inspections
  fprintf('writing out smoothed fieldmaps...');

  % write out fieldmap and fieldmap resampled to match the original fieldmap
  for p=1:length(smoothfieldmaps)
    if ~isempty(smoothfieldmaps{p})
      todo = {{1 ''} {1/3 'ALT'}};
      for qqq=1:length(todo)
        imwrite(uint8(255*makeimagestack(smoothfieldmaps{p},todo{qqq}{1}*[-1 1]*fmapsc(p))),jet(256),sprintf('%s/fieldmapsmoothed%s%02d.png',figuredir,todo{qqq}{2},p));
        imwrite(uint8(255*makeimagestack(processmulti(@imresizedifferentfov,smoothfieldmaps{p},episize(1:2), ...
          sizefull(fieldmaps{p},2),fieldmap_vox_sizes{p}(1:2)),todo{qqq}{1}*[-1 1]*fmapsc(p))),jet(256), ...
          sprintf('%s/fieldmapsmoothedbacksampled%s%02d.png',figuredir,todo{qqq}{2},p));
      end
    end
  end

  fprintf('done.\n');


  reportmemoryandtime;

% deal with epifieldmapasst
finalfieldmaps = cell(1,length(epis));  % we need this to exist in all epi cases
  fprintf('deal with epi fieldmap assignment and time interpolation...');

  % calculate the final fieldmaps [we use single to save on memory]
  if ~isequalwithequalnans(epifieldmapasst,NaN)
    for p=1:length(epifieldmapasst)
      if epifieldmapasst{p} ~= 0
        fn = epifieldmapasst{p};
        
        % if scalar, just use as-is, resulting in X x Y x Z
        if isscalar(fn)
          finalfieldmaps{p} = single(smoothfieldmaps{fn});
        
        % if two-element vector, do the interpolation, resulting in X x Y x Z x T     [[OUCH. THIS DOUBLES THE MEMORY USAGE]]
        else
          finalfieldmaps{p} = single(permute(interp1(fieldmaptimes,permute(catcell(4,smoothfieldmaps),[4 1 2 3]), ...
                                                     linspace(fn(1),fn(2),size(epis{p},4)),fieldmaptimeinterp,'extrap'),[2 3 4 1]));
        end
        
      end
    end
  end
  fprintf('done.\n');


  reportmemoryandtime;

% write out EPI undistort inspections
  fprintf('writing out inspections of what the undistortion is like...');

  % undistort the first and last volume [NOTE: temp is int16]
  temp = cellfun(@(x,y,z) undistortvolumes(x(:,:,:,[1 end]),episize, ...
                 y(:,:,:,[1 end])*(epireadouttime/1000)*(epidim(abs(z))/epiinplanematrixsize(2)), ...
                 z,[]),epis,finalfieldmaps,num2cell(epiphasedir),'UniformOutput',0);

  % inspect first and last of each run
  viewmovie(catcell(4,cellfun(@(x) double(x(:,:,:,1)),temp,'UniformOutput',0)),sprintf('%s/EPIundistort/image%%04da',figuredir));
  viewmovie(catcell(4,cellfun(@(x) double(x(:,:,:,2)),temp,'UniformOutput',0)),sprintf('%s/EPIundistort/image%%04db',figuredir));

  fprintf('done.\n');


  reportmemoryandtime;


