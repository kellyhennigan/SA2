#!/usr/bin/python

import os,sys

	
##################### fit glm using 3dDeconvolve #####################################################################
# EDIT AS NEEDED:

#data_dir = '/Volumes/blackbox/SA2/data/'		# experiment main data directory
data_dir = '/home/hennigan/SA2/data/'	

subjects = ['18','19','23','24','25','27']						# subject (string) to process

out_str = 'glm3'					# string for output files

##########################################################################################


for subject in subjects:

	print '********** GLM FITTING FOR SUBJECT '+subject+' **********'

	out_str = subject+'_'+out_str

	# define subject-specific directories
	subj_dir = data_dir+str(subject) # subject dir
	pp_dir = subj_dir+'/func_proc/'	 # func_proc dir
	res_dir = subj_dir+'/results/'	 # results dir
	if not os.path.exists(res_dir):
		os.makedirs(res_dir)
	
	os.chdir(subj_dir) 				 # cd to subj directory
	cdir = os.getcwd()
	print 'Current working directory: '+cdir

	# NOTE: all input file paths in the 3dDeconvolve command are relative to the subject's directory

	cmd = ('3dDeconvolve '
		#'-nodata 1956 1.5 '				# nodata option - comment this out if data is provided as -input
		'-input func_proc/pp_run1+tlrc. func_proc/pp_run2+tlrc. func_proc/pp_run3+tlrc. func_proc/pp_run4+tlrc. func_proc/pp_run5+tlrc. func_proc/pp_run6+tlrc. '
		#'-input1D func_proc/vox_ts '	
		'-jobs 4 '					# split up into this many sub-processes if using a multi CPU machine 	
		'-xjpeg '+res_dir+out_str+'Xmat ' 			# saves out an image of the design matrix as filename
		#'-mask func_proc/func_mask+tlrc. '		# or -automask
		'-mask '+data_dir+'tlrc_mb_cube_mask.nii.gz '		
		'-polort 4 '					# number of baseline regressors per run
		'-dmbase '					# de-mean baseline regressors
		'-xout ' 					# writes out the design matrix to the screen
		'-num_stimts 37 ' 				# number of stimulus time series that will be used
		'-stim_file 1 regs/gain+1_base_can_runALL  -stim_label 1 gain+1_base '
		'-stim_file 2 regs/gain+PE_base_can_runALL -stim_label 2 gain+PE_base '
		'-stim_file 3 regs/gain0_base_can_runALL -stim_label 3 gain0_base '
		'-stim_file 4 regs/gain-PE_base_can_runALL -stim_label 4 gain-PE_base '
		'-stim_file 5 regs/loss0_base_can_runALL -stim_label 5 loss0_base '
		'-stim_file 6 regs/loss+PE_base_can_runALL -stim_label 6 loss+PE_base '
		'-stim_file 7 regs/loss-1_base_can_runALL -stim_label 7 loss-1_base '
		'-stim_file 8 regs/loss-PE_base_can_runALL -stim_label 8 loss-PE_base '
		'-stim_file 9 regs/gain+1_stress_can_runALL -stim_label 9 gain+1_stress '
		'-stim_file 10 regs/gain+PE_stress_can_runALL -stim_label 10 gain+PE_stress '
		'-stim_file 11 regs/gain0_stress_can_runALL -stim_label 11 gain0_stress '
		'-stim_file 12 regs/gain-PE_stress_can_runALL -stim_label 12 gain-PE_stress '
		'-stim_file 13 regs/loss0_stress_can_runALL -stim_label 13 loss0_stress '
		'-stim_file 14 regs/loss+PE_stress_can_runALL -stim_label 14 loss+PE_stress '
		'-stim_file 15 regs/loss-1_stress_can_runALL -stim_label 15 loss-1_stress '
		'-stim_file 16 regs/loss-PE_stress_can_runALL -stim_label 16 loss-PE_stress '
		'-stim_file 17 regs/contextevent_base_can_runALL -stim_label 17 neutralcue '
		'-stim_file 18 regs/contextevent_stress_can_runALL -stim_label 18 shockcue '
		'-stim_file 19 regs/shock_can_runALL -stim_label 19 shock '
		'-stim_file 20 "regs/cuepair1_can_runALL[0]" -stim_label 20 cuepair1a '
		'-stim_file 21 "regs/cuepair1_can_runALL[1]" -stim_label 21 cuepair1b '
		'-stim_file 22 "regs/cuepair1_can_runALL[2]" -stim_label 22 cuepair1c '
		'-stim_file 23 "regs/cuepair1_can_runALL[3]" -stim_label 23 cuepair1d '
		'-stim_file 24 "regs/cuepair1_can_runALL[4]" -stim_label 24 cuepair1e '
		'-stim_file 25 "regs/cuepair1_can_runALL[5]" -stim_label 25 cuepair1f '
		'-stim_file 26 "regs/cuepair2_can_runALL[0]" -stim_label 26 cuepair2a '
		'-stim_file 27 "regs/cuepair2_can_runALL[1]" -stim_label 27 cuepair2b '
		'-stim_file 28 "regs/cuepair2_can_runALL[2]" -stim_label 28 cuepair2c '
		'-stim_file 29 "regs/cuepair2_can_runALL[3]" -stim_label 29 cuepair2d '
		'-stim_file 30 "regs/cuepair2_can_runALL[4]" -stim_label 30 cuepair2e '
		'-stim_file 31 "regs/cuepair2_can_runALL[5]" -stim_label 31 cuepair2f '
		'-stim_file 32 "regs/motion_runALL[0]" -stim_base 32 -stim_label 32 Roll '
		'-stim_file 33 "regs/motion_runALL[1]" -stim_base 33 -stim_label 33 Pitch '
		'-stim_file 34 "regs/motion_runALL[2]" -stim_base 34 -stim_label 34 Yaw '
		'-stim_file 35 "regs/motion_runALL[3]" -stim_base 35 -stim_label 35 dS '
		'-stim_file 36 "regs/motion_runALL[4]" -stim_base 36 -stim_label 36 dL '
		'-stim_file 37 "regs/motion_runALL[5]" -stim_base 37 -stim_label 37 dP '
		'-num_glt 10 '
		'-glt_label 1 shockcue-neutralcue -gltsym "SYM: +shockcue -neutralcue" '
		'-glt_label 2 gain+1-gain0 -gltsym "SYM: +gain+1_base +gain+1_stress -gain0_base -gain0_stress" '
		'-glt_label 3 loss0-loss-1 -gltsym "SYM: +loss0_base +loss0_stress -loss-1_base -loss-1_stress" '
		'-glt_label 4 gain+PE_base_vs_stress -gltsym "SYM: +gain+PE_base -gain+PE_stress " '
		'-glt_label 5 gain-PE_base_vs_stress -gltsym "SYM: +gain-PE_base -gain-PE_stress " '	
		'-glt_label 6 loss+PE_base_vs_stress -gltsym "SYM: +loss+PE_base -loss+PE_stress " '
		'-glt_label 7 loss-PE_base_vs_stress -gltsym "SYM: +loss-PE_base -loss-PE_stress " '
		'-glt_label 8 cuepairs -gltsym "SYM: +cuepair1a +cuepair1b +cuepair1c +cuepair1d +cuepair1e +cuepair1f +cuepair2a +cuepair2b +cuepair2c +cuepair2d +cuepair2e +cuepair2f " '
		'-glt_label 9 gain+PE -gltsym "SYM: +gain+PE_base +gain+PE_stress" '
		'-glt_label 10 gainALLPE -gltsym "SYM: +gain+PE_base +gain+PE_stress +gain-PE_base +gain-PE_stress" '
		#'-errts '+res_dir+out_str+'_errts ' 			# to save out the residual time series
		'-tout ' 					# output the partial and full model F
		'-rout ' 					# output the partial and full model R2
		'-bucket '+res_dir+out_str+' ' 			# save out all info to filename w/prefix
		'-cbucket '+res_dir+out_str+'_B ') 		# save out only regressor coefficients to filename w/prefix


#############
# RUN IT

	print cmd
	os.system(cmd)

	print '********** DONE WITH SUBJECT '+subject+' **********'

print 'finished subject loop'






