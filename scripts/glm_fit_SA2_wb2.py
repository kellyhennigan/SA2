 #!/usr/bin/python

import os,sys

	
##################### fit glm using 3dDeconvolve #####################################################################
# EDIT AS NEEDED:

data_dir = '/Volumes/blackbox/SA2/data/'		# experiment main data directory
#data_dir = '/home/hennigan/SA2/data/'	
#data_dir = '/home/kelly/SA2/data/'

subjects = ['16']			# subject (string) to process

out_str = 'glm_wb2'					# string for output files

out_dir = data_dir+'results_wb2/'  	# directory for out files 

stim_files = ['regs/gain+1_base_can_runALL',
		'regs/gain_+PE_base_can_runALL',
		'regs/gain0_base_can_runALL',
		'regs/gain_-PE_base_can_runALL',
		'regs/loss0_base_can_runALL',
		'regs/loss_+PE_base_can_runALL',
		'regs/loss-1_base_can_runALL',
		'regs/loss_-PE_base_can_runALL',
		'regs/gain+1_stress_can_runALL',
		'regs/gain_+PE_stress_can_runALL',
		'regs/gain0_stress_can_runALL',
		'regs/gain_-PE_stress_can_runALL',
		'regs/loss0_stress_can_runALL',
		'regs/loss_+PE_stress_can_runALL',
		'regs/loss-1_stress_can_runALL',
		'regs/loss_-PE_stress_can_runALL',
		'regs/contextevent_base_can_runALL',
		'regs/contextevent_stress_can_runALL',	
		'regs/shock_can_runALL',
		'"regs/cuepair1_can_runALL[0]"',
		'"regs/cuepair1_can_runALL[1]"',
		'"regs/cuepair1_can_runALL[2]"',
		'"regs/cuepair1_can_runALL[3]"',
		'"regs/cuepair1_can_runALL[4]"',
		'"regs/cuepair1_can_runALL[5]"',
		'"regs/cuepair2_can_runALL[0]"',
		'"regs/cuepair2_can_runALL[1]"',
		'"regs/cuepair2_can_runALL[2]"',
		'"regs/cuepair2_can_runALL[3]"',
		'"regs/cuepair2_can_runALL[4]"',
		'"regs/cuepair2_can_runALL[5]"']
		
stim_base_files = ['"regs/motion_z_runALL[0]"',
		'"regs/motion_z_runALL[1]"',
		'"regs/motion_z_runALL[2]"',
		'"regs/motion_z_runALL[3]"',
		'"regs/motion_z_runALL[4]"',
		'"regs/motion_z_runALL[5]"']

		
stim_labels = ['gain+1_base','gain+PE_base','gain0_base','gain-PE_base',
		'loss0_base','loss+PE_base','loss-1_base','loss-PE_base',
		'gain+1_stress','gain+PE_stress','gain0_stress','gain-PE_stress',
		'loss0_stress','loss+PE_stress','loss-1_stress','loss-PE_stress',
		'neutralcue','shockcue','shock',
		'cuepair1a','cuepair1b','cuepair1c','cuepair1d','cuepair1e','cuepair1f',
		'cuepair2a','cuepair2b','cuepair2c','cuepair2d','cuepair2e','cuepair2f',
		'Roll','Pitch','Yaw','dS','dL','dP']


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
		'-input func_proc/pp_run1+tlrc. func_proc/pp_run2+tlrc. func_proc/pp_run3+tlrc. func_proc/pp_run4+tlrc. func_proc/pp_run5+tlrc. func_proc/pp_run6+tlrc. '
		#'-input1D func_proc/vox_ts '	
		#'-jobs 4 '					# split up into this many sub-processes if using a multi CPU machine 	
		'-xjpeg '+out_dir+this_out_str+'Xmat ' 			# saves out an image of the design matrix as filename
		#'-mask func_proc/func_mask+tlrc. '			# or -automask
		'-mask '+data_dir+'ROIs/group_mask+tlrc '		
		'-polort 4 '					# number of baseline regressors per run
		'-dmbase '						# de-mean baseline regressors
		'-xout ' 						# writes out the design matrix to the screen
 		+ stim_str +					# string defining stim inputs
		'-num_glt 12 '					# # of contrasts
		'-glt_label 1 gain_win-nothing -gltsym "SYM: +gain+1_base -gain0_base +gain+1_stress -gain0_stress " '
		'-glt_label 2 gain+RPE -gltsym "SYM: +gain+PE_base +gain+PE_stress " '
		'-glt_label 3 gain-RPE -gltsym "SYM: +gain-PE_base +gain-PE_stress " '
		'-glt_label 4 gainRPE -gltsym "SYM: +gain+PE_base +gain-PE_base +gain+PE_stress +gain-PE_stress " '
		'-glt_label 5 gainSPE -gltsym "SYM: +gain+PE_base -gain-PE_base +gain+PE_stress -gain-PE_stress " '
		'-glt_label 6 gain_win-nothing_B-S -gltsym "SYM: +gain+1_base -gain0_base -gain+1_stress +gain0_stress " '
		'-glt_label 7 gain+RPE_B-S -gltsym "SYM: +gain+PE_base -gain+PE_stress " '
		'-glt_label 8 gain-RPE_B-S -gltsym "SYM: +gain-PE_base -gain-PE_stress " '
		'-glt_label 9 gainRPE_B-S -gltsym "SYM: +gain+PE_base +gain-PE_base -gain+PE_stress -gain-PE_stress " '
		'-glt_label 10 gainSPE_B-S -gltsym "SYM: +gain+PE_base -gain-PE_base -gain+PE_stress +gain-PE_stress " '
		'-glt_label 11 shockcue-neutralcue -gltsym "SYM: +shockcue -neutralcue" '
		'-glt_label 12 cue_period -gltsym "SYM: +cuepair1a +cuepair1b +cuepair1c +cuepair1d +cuepair1e +cuepair1f +cuepair2a +cuepair2b +cuepair2c +cuepair2d +cuepair2e +cuepair2f " '
		#'-errts '+out_dir+this_out_str+'_errts ' 			# to save out the residual time series
 		#'-tout ' 					# output the partial and full model F
 		#'-rout ' 					# output the partial and full model R2
 		#'-bucket '+out_dir+this_out_str+' ' 			# save out all info to filename w/prefix
 		'-cbucket '+out_dir+this_out_str+'_B ') 		# save out only regressor coefficients to filename w/prefix
 
 
# #############
# # RUN IT
# 
	print cmd
	os.system(cmd)

	print '********** DONE WITH SUBJECT '+subject+' **********'

print 'finished subject loop'

