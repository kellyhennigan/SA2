<<<<<<< HEAD
 #!/usr/bin/python
=======
	 #!/usr/bin/python
>>>>>>> 16c25c6ec9c1190a3b298fb8e9f34a7a31a8fee8

import os,sys

	
##################### fit glm using 3dDeconvolve #####################################################################
# EDIT AS NEEDED:

<<<<<<< HEAD
data_dir = '/Volumes/blackbox/SA2/data/'		# experiment main data directory
#data_dir = '/home/hennigan/SA2/data/'	
#data_dir = '/home/kelly/SA2/data/'
=======
#data_dir = '/Volumes/blackbox/SA2/data/'		# experiment main data directory
#data_dir = '/home/hennigan/SA2/data/'	
data_dir = '/home/kelly/SA2/data/'
>>>>>>> 16c25c6ec9c1190a3b298fb8e9f34a7a31a8fee8

subjects = ['17']			# subject (string) to process

out_str = 'glm_mb'					# string for output files

##########################################################################################


for subject in subjects:

	print '********** GLM FITTING FOR SUBJECT '+subject+' **********'

	this_out_str = subject+'_'+out_str

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
	
	i = 1  # stim counter 
	
	stim_files = ['regs/gain_base_can_runALL',
		'regs/gain_param_base_can_runALL',
		'regs/gainPE_base_can_runALL',
		'regs/loss_base_can_runALL',
		'regs/loss_param_base_can_runALL',
		'regs/lossPE_base_can_runALL',
		'regs/gain_stress_can_runALL',
		'regs/gain_param_stress_can_runALL',
		'regs/gainPE_stress_can_runALL',
		'regs/loss_stress_can_runALL',
		'regs/loss_param_stress_can_runALL',
		'regs/lossPE_stress_can_runALL',
		'regs/contextevent_base_can_runALL',
		'regs/contextevent_stress_can_runALL',	
<<<<<<< HEAD
		'regs/shock_can_runALL',
=======
		'regs/shock_can_runALL',			
>>>>>>> 16c25c6ec9c1190a3b298fb8e9f34a7a31a8fee8
		'"regs/cuepair1_can_runALL[0]"',
		'"regs/cuepair1_can_runALL[1]"',
		'"regs/cuepair1_can_runALL[2]"',
		'"regs/cuepair1_can_runALL[3]"',
<<<<<<< HEAD
		'"regs/cuepair1_can_runALL[4]"',
		'"regs/cuepair1_can_runALL[5]"',
=======
>>>>>>> 16c25c6ec9c1190a3b298fb8e9f34a7a31a8fee8
		'"regs/cuepair2_can_runALL[0]"',
		'"regs/cuepair2_can_runALL[1]"',
		'"regs/cuepair2_can_runALL[2]"',
		'"regs/cuepair2_can_runALL[3]"',
<<<<<<< HEAD
		'"regs/cuepair2_can_runALL[4]"',
		'"regs/cuepair2_can_runALL[5]"',
=======
>>>>>>> 16c25c6ec9c1190a3b298fb8e9f34a7a31a8fee8
		'"regs/motion_z_runALL[0]"',
		'"regs/motion_z_runALL[1]"',
		'"regs/motion_z_runALL[2]"',
		'"regs/motion_z_runALL[3]"',
		'"regs/motion_z_runALL[4]"',
		'"regs/motion_z_runALL[5]"']

		
	stim_labels = ['gain_base','gain_param_base','gain_PE_base',
		'loss_base','loss_param_base','loss_PE_base',
		'gain_stress','gain_param_stress','gain_PE_stress',
		'loss_stress','loss_param_stress','loss_PE_stress',
		'neutralcue','shockcue','shock',
<<<<<<< HEAD
		'cuepair1a','cuepair1b','cuepair1c','cuepair1d','cuepair1e','cuepair1f',
		'cuepair2a','cuepair2b','cuepair2c','cuepair2d','cuepair2e','cuepair2f',
=======
		'cuepair1a','cuepair1b','cuepair1c','cuepair1d',
		'cuepair2a','cuepair2b','cuepair2c','cuepair2d',
>>>>>>> 16c25c6ec9c1190a3b298fb8e9f34a7a31a8fee8
		'Roll','Pitch','Yaw','dS','dL','dP']

	
	stim_str = '-num_stimts '+str(len(stim_files))+' '  # string defining the stim files and labels
	
	i=0  # stim counter
	
	for stim_file in stim_files:
	 	stim_str = stim_str + '-stim_file '+str(i+1)+' '+stim_file+' -stim_label '+str(i+1)+' '+stim_labels[i]+' '
	 	i=i+1
	

	cmd = ('3dDeconvolve '
		#'-nodata 1956 1.5 '				# nodata option - comment this out if data is provided as -input
<<<<<<< HEAD
=======
		#'-input func_proc/pp_run1+tlrc. func_proc/pp_run2+tlrc. func_proc/pp_run3+tlrc. func_proc/pp_run4+tlrc. func_proc/pp_run5+tlrc. func_proc/pp_run6+tlrc. '
>>>>>>> 16c25c6ec9c1190a3b298fb8e9f34a7a31a8fee8
		'-input func_proc/pp_run1+tlrc. func_proc/pp_run2+tlrc. func_proc/pp_run3+tlrc. func_proc/pp_run4+tlrc. '
		#'-input1D func_proc/vox_ts '	
		'-jobs 2 '					# split up into this many sub-processes if using a multi CPU machine 	
		'-xjpeg '+res_dir+this_out_str+'Xmat ' 			# saves out an image of the design matrix as filename
		#'-mask func_proc/func_mask+tlrc. '			# or -automask
		'-mask '+data_dir+'ROIs/tlrc_mb_cube_mask.nii.gz '		
		'-polort 4 '					# number of baseline regressors per run
		'-dmbase '						# de-mean baseline regressors
		'-xout ' 						# writes out the design matrix to the screen
 		+ stim_str +					# string defining stim inputs
		'-num_glt 10 '					# # of contrasts
		'-glt_label 1 shockcue-neutralcue -gltsym "SYM: +shockcue -neutralcue" '
		'-glt_label 2 gain_param -gltsym "SYM: +gain_param_base +gain_param_stress " '
		'-glt_label 3 gain_PE -gltsym "SYM: +gain_PE_base +gain_PE_stress " '
		'-glt_label 4 loss_param -gltsym "SYM: +loss_param_base +loss_param_stress " '
		'-glt_label 5 loss_PE -gltsym "SYM: +loss_PE_base +loss_PE_stress " '
		'-glt_label 6 gain_param_base-stress -gltsym "SYM: +gain_param_base -gain_param_stress " '
		'-glt_label 7 gain_PE_base-stress -gltsym "SYM: +gain_PE_base -gain_PE_stress " '
		'-glt_label 8 loss_param_base-stress -gltsym "SYM: +loss_param_base -loss_param_stress " '
		'-glt_label 9 loss_PE_base-stress -gltsym "SYM: +loss_PE_base -loss_PE_stress " '
<<<<<<< HEAD
		'-glt_label 10 cuepairs -gltsym "SYM: +cuepair1a +cuepair1b +cuepair1c +cuepair1d +cuepair1e +cuepair1f +cuepair2a +cuepair2b +cuepair2c +cuepair2d +cuepair2e +cuepair2f " '
=======
		'-glt_label 10 cuepairs -gltsym "SYM: +cuepair1a +cuepair1b +cuepair1c +cuepair1d +cuepair2a +cuepair2b +cuepair2c +cuepair2d " '
>>>>>>> 16c25c6ec9c1190a3b298fb8e9f34a7a31a8fee8
# 		'-errts '+res_dir+this_out_str+'_errts ' 			# to save out the residual time series
 		'-tout ' 					# output the partial and full model F
 		'-rout ' 					# output the partial and full model R2
 		'-bucket '+res_dir+this_out_str+' ' 			# save out all info to filename w/prefix
 		'-cbucket '+res_dir+this_out_str+'_B ') 		# save out only regressor coefficients to filename w/prefix
 
 
# #############
# # RUN IT
# 
	print cmd
	os.system(cmd)

	print '********** DONE WITH SUBJECT '+subject+' **********'

print 'finished subject loop'

<<<<<<< HEAD
=======

>>>>>>> 16c25c6ec9c1190a3b298fb8e9f34a7a31a8fee8
