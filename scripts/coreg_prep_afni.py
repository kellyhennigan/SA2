#!/usr/bin/python

# filename: coreg_afni.py
# script to coregister t1,t2,pd, and func data from experiment SA2. I'm using the 
# epi calibration scan from the first run because it should be in good alignment with
# the func_ref_vol (they were separated in time by tends of seconds and it has the same 
# slice prescription) but it has better contrast than the func_ref_vol, so it could help 
# improve cross-modality alignment.

# for every coregistered transform (e.g., vol A to vol B) I'm saving the 12-parameter 
# affine xform for going from space A to B in a file called, e.g., A_to_B.Xaff12.1D
# 
# with the hope that I will eventually be able to concatenate them using cat_matvec like so:
# 
# cat_matvec ref1_to_t1.Xaff12.1D t1_to_tlrc.Xaff12.1D > ref1_to_tlrc.Xaff12.1D
# 
# then use either 3dWarp or 3dAllineate to xform functional data from native space to tlrc space:
# 
# 3dWarp -matvec_in2out ref1_to_tlrc.Xaff12.1D -prefix ref1_tlrc ref1+orig.
# or
# 3dAllineate -cubic -1Dmatrix_apply ref1_to_tlrc.Xaff12.1D -prefix ref1_tlrc2 rcal1.nii
# 
# this hasn't worked yet tho :(

import os,sys



##########################################################################################
# EDIT AS NEEDED:

#data_dir = '/Volumes/blackbox/SA2/data/'		# experiment main data directory
data_dir = '/home/hennigan/SA2/data/'	

subjects = ['17']			# subject to process

##########################################################################################


for subject in subjects:
	print 'coregistering data for subject '+subject

	# define subject-specific directories
	subj_dir = data_dir+str(subject) # subject dir
	raw_dir = subj_dir+'/raw'		 # raw dir
	pp_dir = subj_dir+'/func_proc'	 # func_proc dir
	
	os.chdir(raw_dir) 				 # cd to func_proc directory
	cdir = os.getcwd()
	print 'Current working directory: '+cdir
	

	######### skull strip t1,t2,pd images

	cmd = '3dSkullStrip -prefix t1_ns -input t1.nii.gz'  		# t1-weighted volume 
	os.system(cmd)

	cmd = '3dSkullStrip -prefix t2_ns -input t2.nii.gz'			# t2-weighted volume
	os.system(cmd)

	cmd = '3dSkullStrip -prefix pd_ns -input pd.nii.gz'			# pd volume
	os.system(cmd)

	cmd = 'mv *_ns+orig* '+pp_dir					# move files to func_proc dir
	os.system(cmd)


	#cmd = '3dAutomask -apply_prefix func_ref_ns func_ref_vol.nii.gz' 	# func_ref scan 
	#os.system(cmd)
	#cmd = '3dAutomask -apply_prefix cal_ns cal1.nii.gz' 	# calibration scan
	#os.system(cmd)


	# cd to pp directory
	# os.chdir(pp_dir) 				

	
	
