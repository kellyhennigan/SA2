#!/usr/bin/python

import sys
import os

# run 3dDeconvolve
	
# transform the stats into tlrc space

# transform the stats into bs norm space

# mv transformed files to results_tlrc and results_bs directory; this WILL write over old files in the new directory that have the same name


3dDeconvolve \

#-input func_proc/ssrarun_ALL.nii.gz
#or
#-input func_proc/vox_ts.1D
#or
-nodata [1956 [1.5]] \

-xjpeg Xmat \ # saves out an image of the design matrix as filename

-mask func_proc/func_mask+orig  \
#or
#-automask

#-censor censor_trs.1D  # file indexing TRs to censor (remember, index starts with 0!)

-concat func_proc/concat.1D  \# file that has an index of the first volume for each scan run

-polort 4  \# number of baseline regressors per run

# -nolegendre # turns off the default of using legendre polynomials (do this for more direct comparison of model fits to matlab

-xout \ # writes out the design matrix to the screen

-num_stimts K \ # number of stimulus time series that will be used

-stim_file 1 'regs/gain+1_base_can_runALL' -stim_label 1 gain+1_base \
-stim_file 2 'regs/gain+PE_base_can_runALL' -stim_label 2 gain+PE_base \
-stim_file 3 'regs/gain0_base_can_runALL' -stim_label 3 gain0_base \
-stim_file 4 'regs/gain-PE_base_can_runALL'-stim_label 4 gain-PE_base \
-stim_file 5 'regs/loss0_base_can_runALL' -stim_label 5 loss0_base \
-stim_file 6 'regs/loss+PE_base_can_runALL' -stim_label 6 loss+PE_base \
-stim_file 7 'regs/loss-1_base_can_runALL' -stim_label 7 loss-1_base \
-stim_file 8 'regs/loss-PE_base_can_runALL' -stim_label 8 loss-PE_base \
-stim_file 9 'regs/gain+1_stress_can_runALL' -stim_label 9 gain+1_stress \
-stim_file 10 'regs/gain+PE_stress_can_runALL' -stim_label 10 gain+PE_stress \
-stim_file 11 'regs/gain0_stress_can_runALL' -stim_label 11 gain0_stress \
-stim_file 12 'regs/gain-PE_stress_can_runALL'-stim_label 12 gain-PE_stress \
-stim_file 13 'regs/loss0_stress_can_runALL' -stim_label 13 loss0_stress \
-stim_file 14 'regs/loss+PE_stress_can_runALL' -stim_label 14 loss+PE_stress \
-stim_file 15 'regs/loss-1_stress_can_runALL' -stim_label 15 loss-1_stress \
-stim_file 16 'regs/loss-PE_stress_can_runALL' -stim_label 16 loss-PE_stress \
-stim_file 17 'regs/contextevent_base_can_runALL' -stim_label 17 neutralcue \
-stim_file 18 'regs/contextevent_stress_can_runALL' -stim_label 18 shockcue \
-stim_file 19 'regs/shock_can_runALL' -stim_label 19 shock \
-stim_file 20 'regs/cuepair1_can_runALL_concat' -stim_label 20 cuepair1 \
-stim_file 21 'regs/cuepair2_can_runALL_concat' -stim_label 21 cuepair2 \

#or
-stim_file 22 'regs/motionRegs_concat[1]' -stim_base 22 -stim_label 22 Roll \
-stim_file 23 'regs/motionRegs_concat[1]' -stim_base 23 -stim_label 23 Pitch \
-stim_file 24 'regs/motionRegs_concat[1]' -stim_base 24 -stim_label 24 Yaw \
-stim_file 25 'regs/motionRegs_concat[1]' -stim_base 25 -stim_label 25 dS \
-stim_file 26 'regs/motionRegs_concat[1]' -stim_base 26 -stim_label 26 dL \
-stim_file 27 'regs/motionRegs_concat[1]' -stim_base 27 -stim_label 27 dP \


-num_glt 1 \# number of general linear tests

-glt_label 1 shockcue-neutralcue \
-gltsym 'SYM: +shockcue -neutralcue' \

-errts glm_errts # to save out the residual time series

-fout \ # output the partial and full model F

-rout \# output the partial and full model R2

-bucket glm_res \ # save out all info to filename w/prefix

-cbucket B \# save out only regressor coefficients to filename w/prefix







