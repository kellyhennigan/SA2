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

subjects = ['18']			# subject to process
runs = ['1','2','3','4','5','6'] # functional scan runs

##########################################################################################


for subject in subjects:

	print 'WORKING ON SUBJECT '+subject

	# define subject-specific directories
	subj_dir = data_dir+str(subject) # subject dir
	raw_dir = subj_dir+'/raw'		 # raw dir
	pp_dir = subj_dir+'/func_proc'	 # func_proc dir
	
	
	######### skull strip t1,t2,pd images
	
	os.chdir(raw_dir) 				 # cd to raw directory
	
	cmd = '3dSkullStrip -prefix t1 -input t1.nii.gz'  		# t1-weighted volume 
	os.system(cmd)

	cmd = '3dSkullStrip -prefix t2 -input t2.nii.gz'			# t2-weighted volume
	os.system(cmd)

	cmd = '3dSkullStrip -prefix pd -input pd.nii.gz'			# pd volume
	os.system(cmd)

	cmd = 'mv *+orig* '+pp_dir					# move files to func_proc dir
	os.system(cmd)

	os.chdir(pp_dir) 	 # cd to pp directory			


	######### coregister calibration scans to functional reference scan  
# 	print 'coregistering calibration scan to functional reference volume for SUBJECT '+subject+' ...'
# 	cmd = '3dvolreg -base ref1.nii.gz -zpad 4 -1Dfile vr_cal1 -prefix rcal1 cal1.nii.gz'
# 	os.system(cmd)
# 	print 'done'
	
	
	################### method 1: register everything to the t1 native space > tlrc space
	

 	# ##### normalize t1 to tlrc
#  	print 'normalizating t1 scan to tlrc template for SUBJECT '+subject+' ...'
#  	cmd = '@auto_tlrc -base '+data_dir+'TT_N27+tlrc. -input t1+orig. -no_ss'
#  	os.system(cmd)
#  	print 'done'
# 
# 	
# 	######### align t2 & pd > t1 in native and tlrc space 
# 	# NOTE: this will probably require cropping the calibration scan to match the # of slices of the pd/t2-w scan
# 	print 'aligning t2 and pd data to t1 in native & tlrc space for SUBJECT '+subject+' ...'
# 	cmd = 'align_epi_anat.py -dset1 t1+orig. -dset2 pd+orig. -dset2to1 -partial_coverage -tlrc_apar t1+tlrc -big_move -dset1_strip None -dset2_strip None -master_tlrc 1.6 -child_dset2 t2+orig.'
# 	os.system(cmd)
# 	print 'done'
# 	#os.rename('pd_ns_al_mat.aff12.1D','pd_to_ref1_mat.aff12.1D')  #  rename xform files 
# 	#os.rename('pd_ns_al_e2a_only_mat.aff12.1D','ref1_to_pd_mat.aff12.1D')
# 
# 
# 	
# 	######### align epi > t1 in native and tlrc space 
# 	# NOTE: this may require using the nudge plug-in first
# 	print 'aligning functional data to t1 in native & tlrc space for SUBJECT '+subject+' ...'
# 	cmd = 'align_epi_anat.py -anat t1+orig. -epi rcal1+orig. -epi_base 0 -epi2anat -partial_coverage -tlrc_apar t1+tlrc -anat_has_skull no -epi_strip 3dAutomask -big_move -master_tlrc 1.6 -tshift off -volreg off -AddEdge -child_epi ref.nii.gz psraorun1+orig. psraorun2+orig. psraorun3+orig. psraorun4+orig. psraorun5+orig. psraorun6+orig.'
# 	os.system(cmd)
# 	print 'done'
# 	
	
	################### method 2: register everything to func native space > tlrc space

                      
	######### coregister t1,t2,and pd scans to functional scans
	# NOTE: this may require using the nudge plug-in first
	print 'coregistering t1,t2,pd, and functional data for SUBJECT '+subject+' ...'
	cmd = 'align_epi_anat.py -anat t1+orig. -epi rcal1+orig. -epi_base 0 -anat2epi -partial_coverage -anat_has_skull no -epi_strip 3dAutomask -big_move -AddEdge'
	os.system(cmd)
	cmd = 'align_epi_anat.py -dset1 pd+orig. -dset2 rcal1+orig. -dset1to2 -partial_coverage -big_move -dset1_strip None -dset2_strip 3dAutomask -child_dset1 t2+orig.'
	os.system(cmd)
	print 'done'
	
	
	##### normalize t1 to tlrc
 	print 'normalizating t1 scan to tlrc template for SUBJECT '+subject+' ...'
 	cmd = '@auto_tlrc -base '+data_dir+'TT_N27+tlrc. -input t1_al+orig. -no_ss'
 	os.system(cmd)
 	print 'done'

	##### normalize t2,pd, and functional data to tlrc
 	print 'normalizating func data to  tlrc template for SUBJECT '+subject+' ...'
 	cmd = '@auto_tlrc -apar t1_al+tlrc. -input rcal1+orig. -dxyz 1.6'
 	os.system(cmd)
 	cmd = '@auto_tlrc -apar t1_al+tlrc. -input ref1.nii.gz -dxyz 1.6'
 	os.system(cmd)
 	cmd = '@auto_tlrc -apar t1_al+tlrc. -input pd_al+orig -dxyz 1.6'
 	os.system(cmd)
 	cmd = '@auto_tlrc -apar t1_al+tlrc. -input t2_al+orig -dxyz 1.6'
 	os.system(cmd)
	for r in runs:
		cmd = '@auto_tlrc -apar t1_al+tlrc. -input psraorun'+str(r)+'+orig. -dxyz 1.6'
		os.system(cmd)
		cmd = '3drename psraorun'+str(r)+'+tlrc. pp_run'+str(r)+'+tlrc'
		os.system(cmd)
 	print 'done'

	


	
