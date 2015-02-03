 #!/usr/bin/python

import os,sys

	
##################### fit glm using 3dDeconvolve #####################################################################
# EDIT AS NEEDED:

data_dir = '/Volumes/blackbox/SA2/data/'		# experiment main data directory
#data_dir = '/home/hennigan/SA2/data/'	
#data_dir = '/home/kelly/SA2/data/'

subjects = ['17']			# subject (string) to process

out_str = 'glm_mb2'					# string for output files

out_dir = data_dir+'results_mb2/'  	# directory for out files 

##########################################################################################


# make out directory if its not already defined
if not os.path.exists(out_dir):
	os.makedirs(out_dir)


for subject in subjects:

	print '********** GLM FITTING FOR SUBJECT '+subject+' **********'

	this_out_str = subject+'_'+out_str

	# define subject-specific directories
	subj_dir = data_dir+str(subject) # subject dir
	pp_dir = subj_dir+'/func_proc/'	 # func_proc dir
	
	os.chdir(subj_dir) 				 # cd to subj directory
	cdir = os.getcwd()
	print 'Current working directory: '+cdir

	# NOTE: all input file paths in the 3dDeconvolve command are relative to the subject's directory
	
	i = 1  # stim counter 
	
	stim_files = ['regs/gain_base_can_runALL',
		'regs/gain_outc_base_can_runALL',
		'regs/gain_PE_base_can_runALL',
		'regs/gain_sPE_base_can_runALL',
		'regs/loss_base_can_runALL',
		'regs/loss_outc_base_can_runALL',
		'regs/loss_PE_base_can_runALL',
		'regs/loss_sPE_base_can_runALL',
		'regs/gain_stress_can_runALL',
		'regs/gain_outc_stress_can_runALL',
		'regs/gain_PE_stress_can_runALL',
		'regs/gain_sPE_stress_can_runALL',
		'regs/loss_stress_can_runALL',
		'regs/loss_outc_stress_can_runALL',
		'regs/loss_PE_stress_can_runALL',
		'regs/loss_sPE_stress_can_runALL',
		'regs/contextevent_base_can_runALL',
		'regs/contextevent_stress_can_runALL',	
		'regs/shock_can_runALL',
		'"regs/cuepair1_can_runALL[0]"',
		'"regs/cuepair1_can_runALL[1]"',
		'"regs/cuepair1_can_runALL[2]"',
		'"regs/cuepair1_can_runALL[3]"',
		'"regs/cuepair2_can_runALL[0]"',
		'"regs/cuepair2_can_runALL[1]"',
		'"regs/cuepair2_can_runALL[2]"',
		'"regs/cuepair2_can_runALL[3]"']
		
	stim_base_files = ['func_proc/ventricle_ts',
		'"regs/motion_z_runALL[0]"',
		'"regs/motion_z_runALL[1]"',
		'"regs/motion_z_runALL[2]"',
		'"regs/motion_z_runALL[3]"',
		'"regs/motion_z_runALL[4]"',
		'"regs/motion_z_runALL[5]"']

		
	stim_labels = ['gain_base','gain_outc_base','gain_PE_base','gain_sPE_base',
		'loss_base','loss_outc_base','loss_PE_base','loss_sPE_base',
		'gain_stress','gain_outc_stress','gain_PE_stress','gain_sPE_stress',
		'loss_stress','loss_outc_stress','loss_PE_stress','loss_sPE_stress',
		'neutralcue','shockcue','shock',
		'cuepair1a','cuepair1b','cuepair1c','cuepair1d',
		'cuepair2a','cuepair2b','cuepair2c','cuepair2d',
		'ventricle_ts','Roll','Pitch','Yaw','dS','dL','dP']


	
	stim_str = '-num_stimts '+str(len(stim_labels))+' '  # string defining the stim files and labels
	
	i=0  # stim counter
	
	for stim_file in stim_files:
	 	stim_str = stim_str + '-stim_file '+str(i+1)+' '+stim_file+' -stim_label '+str(i+1)+' '+stim_labels[i]+' '
	 	i=i+1
	
	for stim_base_file in stim_base_files:
	 	stim_str = stim_str + '-stim_file '+str(i+1)+' '+stim_base_file+' -stim_base '+str(i+1)+' -stim_label '+str(i+1)+' '+stim_labels[i]+' '
	 	i=i+1
	

	cmd = ('3dDeconvolve '
		#'-nodata 1956 1.5 '				# nodata option - comment this out if data is provided as -input
		'-input func_proc/pp_run1+tlrc. func_proc/pp_run2+tlrc. func_proc/pp_run3+tlrc. func_proc/pp_run4+tlrc. '
		#'-input1D func_proc/vox_ts '	
		'-jobs 2 '					# split up into this many sub-processes if using a multi CPU machine 	
		'-xjpeg '+out_dir+this_out_str+'Xmat ' 			# saves out an image of the design matrix as filename
		#'-mask func_proc/func_mask+tlrc. '			# or -automask
		#'-mask '+data_dir+'ROIs/group_mask+tlrc '		
		'-mask '+data_dir+'ROIs/tlrc_mb_cube_mask.nii.gz '		
		'-polort 4 '					# number of baseline regressors per run
		'-dmbase '						# de-mean baseline regressors
		'-xout ' 						# writes out the design matrix to the screen
 		+ stim_str +					# string defining stim inputs
		'-num_glt 14 '					# # of contrasts
		'-glt_label 1 gain_win-nothing -gltsym "SYM: +gain_outc_base +gain_outc_stress " '
		'-glt_label 2 gain_win-nothing_base-stress -gltsym "SYM: +gain_outc_base -gain_outc_stress " '
		'-glt_label 3 gain_PE -gltsym "SYM: +gain_PE_base +gain_PE_stress " '
		'-glt_label 4 gain_PE_base-stress -gltsym "SYM: +gain_PE_base -gain_PE_stress " '
		'-glt_label 5 gain_sPE -gltsym "SYM: +gain_sPE_base +gain_sPE_stress " '
		'-glt_label 6 gain_sPE_base-stress -gltsym "SYM: +gain_sPE_base -gain_sPE_stress " '
		'-glt_label 7 loss_win-nothing -gltsym "SYM: +loss_outc_base +loss_outc_stress " '
		'-glt_label 8 loss_win-nothing_base-stress -gltsym "SYM: +loss_outc_base -loss_outc_stress " '
		'-glt_label 9 loss_PE -gltsym "SYM: +loss_PE_base +loss_PE_stress " '
		'-glt_label 10 loss_PE_base-stress -gltsym "SYM: +loss_PE_base -loss_PE_stress " '
		'-glt_label 11 loss_sPE -gltsym "SYM: +loss_sPE_base +loss_sPE_stress " '
		'-glt_label 12 loss_sPE_base-stress -gltsym "SYM: +loss_sPE_base -loss_sPE_stress " '
		'-glt_label 13 shockcue-neutralcue -gltsym "SYM: +shockcue -neutralcue" '
		'-glt_label 14 cue_period -gltsym "SYM: +cuepair1a +cuepair1b +cuepair1c +cuepair1d +cuepair2a +cuepair2b +cuepair2c +cuepair2d" '
# 		'-errts '+out_dir+this_out_str+'_errts ' 			# to save out the residual time series
 		'-tout ' 					# output the partial and full model F
 		'-rout ' 					# output the partial and full model R2
 		'-bucket '+out_dir+this_out_str+' ' 			# save out all info to filename w/prefix
 		'-cbucket '+out_dir+this_out_str+'_B ') 		# save out only regressor coefficients to filename w/prefix
 
 
# #############
# # RUN IT
# 
	print cmd
	os.system(cmd)

	print '********** DONE WITH SUBJECT '+subject+' **********'

print 'finished subject loop'
