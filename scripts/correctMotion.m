function [mcVols,paramsB] = correctMotion(vols,vox_dim,motionRef,...
    motionCutoff,mask,figuredir)



    % make figuredir if necessary
if ~isempty(figuredir)
  mkdirquiet(figuredir);
end

    
if notDefined('motionRef') || isempty(motionRef)
  motionRef = [1 1];
end

if notDefined('motionCutoff') || isempty(motionCutoff)
  motionCutoff = 1/90;
end

if notDefined('mask') || isempty(mask)
  mask = [];
end

% make a mask
  fprintf('\nmaking a mask...');

  [d,tempmn,tempsd] = defineellipse3d(data(:,:,:,1),[],0);
  mcmask = {tempmn tempsd};
   
  mcmaskvol = double(makegaussian3d(epidim,mcmask{:}) > 0.5);
   
  % inspect it
    imwrite(uint8(255*makeimagestack(mcmaskvol,[0 1])),gray(256),sprintf('%s/mcmaskvol.png',figuredir));
  

  fprintf('done.\n');
  

% if we are doing motion correction, then...
fprintf('performing motion correction...');


  % estimate motion parameters from the slice-shifted and undistorted
  [epistemp,mparams] = motioncorrectvolumes(epistemp,cellfun(@(x,y) [x y],repmat({episize},[1 length(epis)]),num2cell(epitr),'UniformOutput',0), ...
    figuredir,motionreference,motioncutoff,[],1,[],[],mcmaskvol,epiignoremcvol,dformat);
          %[epistemp,homogenizemask] = homogenizevolumes(epistemp,[99 1/4 2 2]);  % [],1
  
          
    function [vols,paramsB] = motioncorrectvolumes(vols,volsize,figuredir,ref,cutoff,extratrans,skipreslice, ...
            realignparams,resliceparams,binarymask,epiignoremcvol,dformat)


