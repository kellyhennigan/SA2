#!/usr/bin/python

# filename: coreg_afni.py
# script to coregister t1,t2,pd, and func data from experiment SA2. I'm using the 
# epi calibration scan from the first run because it should be in good alignment with
# the func_ref_vol (they were separated in time by tends of seconds and it has the same 
# slice prescription) but it has better contrast than the func_ref_vol, so it could help 
# improve cross-modality alignment.


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
	

	######### skull strip t1,t2,pd images & mask functional volumes

	cmd = '3dSkullStrip -prefix t1_ns -input t1.nii.gz'  		# t1-weighted volume 
	os.system(cmd)

	cmd = '3dSkullStrip -prefix t2_ns -input t2.nii.gz'			# t2-weighted volume
	os.system(cmd)

	cmd = '3dSkullStrip -prefix pd_ns -input pd.nii.gz'			# pd volume
	os.system(cmd)

	cmd = '3dAutomask -apply_prefix cal_ns cal_run1_v2.nii.gz' 	# calibration scan
	os.system(cmd)

	cmd = 'mv *_ns+orig* '+pp_dir	# move files to func_proc dir
	os.system(cmd)


	# cd to pp directory
	os.chdir(pp_dir) 				

	cmd = '3dAutomask -apply_prefix func_ref_ns func_ref_vol.nii.gz' 	# func_ref scan 
	os.system(cmd)



	######### coregister calibration scan to func_ref
	cmd = '3dvolreg -verbose -base func_ref_ns+orig. -zpad 4 -1Dfile cal2func.1D -prefix cal_ns_al cal_ns+orig.'
	os.system(cmd)


	##### align pd and t2 to registered cal scan
	cmd = 'align_epi_anat.py -anat pd_ns+orig. -epi cal_ns_al+orig. -epi_base 0 -anat2epi -child_anat t2_ns+orig. -anat_has_skull no -epi_strip None -tshift off -partial_coverage'
	os.system(cmd)

	#  rename out files 
	os.rename('pd_ns_al_mat.aff12.1D','pd2func_xform')
	os.rename('pd_ns_al_e2a_only_mat.aff12.1D','func2pd_xform')


	##### align t1 to registered cal scan
	cmd = 'align_epi_anat.py -anat t1_ns+orig. -epi cal_ns_al+orig. -epi_base 0 -anat2epi -anat_has_skull no -epi_strip None -tshift off -partial_coverage -AddEdge'
	os.system(cmd)
		
	#  rename out files 
	os.rename('t1_ns_al_mat.aff12.1D','t12func_xform')
	os.rename('t1_ns_al_e2a_only_mat.aff12.1D','func2t1_xform')


	
