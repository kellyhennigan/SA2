% save motionRegs script

% script to load afni motion estimates text file (estimated using 3dvolreg)
% and save out regressors to include in glm in subject's 'reg' directory

% assumes motion reg file is from afni output: 9 columns in this order:
%                     n = sub-brick index
%                     roll  = rotation about the I-S axis }
%                     pitch = rotation about the R-L axis } degrees CCW
%                     yaw   = rotation about the A-P axis }
%                       dS  = displacement in the Superior direction  }
%                       dL  = displacement in the Left direction      } mm
%                       dP  = displacement in the Posterior direction }
%                    rmsold = RMS difference between input brick and base brick
%                    rmsnew = RMS difference between output brick and base brick

% ****** so only use columns 2-7 as regressors *******

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

subjects = getSA2Subjects();
runs = 1:6;

nVols = 326;


for i=1:19
    subj = subjects{i};
    
    % subj = '29';
    
    
    %%
    expPaths = getSA2Paths(subj);
    
    cd(expPaths.func_proc);
    
    mRegs = [];
    
    for r=runs
        mot = dlmread(['vr_run' num2str(r) '.1D']);
        mRegs(end+1:nVols+end,end+1:end+6) = mot(:,1:6);
    end
    
    cd(expPaths.regs)
    dlmwrite('motion_runALL',mRegs);
    
end
