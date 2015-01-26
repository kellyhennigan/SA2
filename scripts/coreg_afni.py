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

subjects = ['9']			# subject to process

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


	# cd to pp directory
	os.chdir(pp_dir) 				

	#cmd = '3dAutomask -apply_prefix func_ref_ns func_ref_vol.nii.gz' 	# func_ref scan 
	#os.system(cmd)
	#cmd = '3dAutomask -apply_prefix cal_ns cal1.nii.gz' 	# calibration scan
	#os.system(cmd)


	######### coregister calibration scans to ref1 and ref4 
	cmd = '3dvolreg -verbose -base ref1.nii.gz -zpad 4 -1Dfile cal2func1 -prefix rcal1 cal1.nii.gz'
	os.system(cmd)
	#cmd = '3dvolreg -verbose -base ref4.nii.gz -zpad 4 -1Dfile cal2func4 -prefix rcal4 cal4.nii.gz'
	#os.system(cmd)


	######### align ref4 > ref1
	#cmd = 'align_epi_anat.py -dset1 rcal1+orig. -dset2 rcal4+orig -dset2to1 -big_move -partial_coverage -dset1_strip 3dAutomask -dset2_strip 3dAutomask -volreg_method 3dvolreg'
	#os.system(cmd)
	#os.rename('rcal4_al_mat.aff12.1D','ref4_to_ref1.aff12.1D') #  rename xform files 
	#os.rename('rcal1_al_mat.aff12.1D','ref1_to_ref4.aff12.1D')


	##### normalize t1 to tlrc
	cmd = '@auto_tlrc -base /usr/share/afni/atlases/TT_icbm452+tlrc. -input t1_ns+orig. -no_ss'
	os.system(cmd)

	# rename out files 
	cmd = '3drename t1_ns+tlrc t1+tlrc'
	os.system(cmd)
	os.rename('t1_ns_WarpDrive.log','t1_tlrc_WarpDrive.log')
	os.rename('t1_ns.Xaff12.1D','t1_tlrc.Xaff12.1D')
	os.rename('t1_ns.Xat.1D','t1_tlrc.Xat.1D')


	######### align epi > t1 in native and tlrc space 
	# NOTE: this may require using the nudge plug-in first
	cmd = 'align_epi_anat.py -anat t1_ns+orig. -epi rcal1+orig. -epi_base 0 -partial_coverage -tlrc_apar t1+tlrc. -anat_has_skull no -epi_strip 3dAutomask -big_move -epi2anat -child_epi ref.nii.gz psraorun1+orig. psraorun2+orig. psraorun3+orig. psraorun4+orig. psraorun5+orig. psraorun6+orig. -tshift on -AddEdge'
	os.system(cmd)
	#	os.rename('t1_ns_al_mat.aff12.1D','t1_to_ref1_mat.aff12.1D')  #  rename xform files 
	#	os.rename('t1_ns_al_e2a_only_mat.aff12.1D','ref1_to_t1_mat.aff12.1D')


	######### align t2 & pd > t1 in native and tlrc space 
	# NOTE: this will probably require cropping the calibration scan to match the # of slices of the pd/t2-w scan
	cmd = 'align_epi_anat.py -dset1 t1_ns+orig. -dset2 pd_ns+orig. -dset2to1 -partial_coverage -tlrc_apar t1_ns+tlrc. -anat_has_skull no -big_move -child_dset2 t2_ns+orig'
	os.system(cmd)
	#os.rename('pd_ns_al_mat.aff12.1D','pd_to_ref1_mat.aff12.1D')  #  rename xform files 
	#os.rename('pd_ns_al_e2a_only_mat.aff12.1D','ref1_to_pd_mat.aff12.1D')


	
	
	###### normalize calibration & func_reference volumes and func_mask
	#cmd = '@auto_tlrc -apar t1+tlrc. -input cal_ns_al+orig. -dxyz 1.6'
	#os.system(cmd)
	# cmd = '@auto_tlrc -apar t1+tlrc. -input func_ref_ns+orig. -dxyz 1.6'
# 	os.system(cmd)
# 	cmd = '@auto_tlrc -apar t1+tlrc. -input func_mask+orig. -dxyz 1.6'
# 	os.system(cmd)
# 	
# 	# rename out files 
# 	cmd = '3drename cal_ns_al+tlrc cal+tlrc'
# 	os.system(cmd)
# 	cmd = '3drename func_ref_ns+tlrc func_ref+tlrc'
# 	os.system(cmd)
# 	
	
	# ###### finally, normalize functional data	
# 	for r in runs:
# 		cmd = '@auto_tlrc -apar t1+tlrc. -input psraorun'+str(r)+'+orig. -dxyz 1.6'
# 		os.system(cmd)
# 
# 		# rename out files 
# 		cmd = '3drename psraorun'+str(r)+'+tlrc. pp_run'+str(r)+'+tlrc'		
# 		os.system(cmd)
# 	
#@auto_tlrc -apar t1+tlrc. -input psraorun4+orig. -dxyz 1.6
#3drename psraorun4+tlrc. pp_run4+tlrc
	
		

	

###############

	######## apply concatenated matrix transforms on data 
	# cat_matvec 
# 	  3dAllineate -cubic -1Dmatrix_apply X_to_Y.aff12.1D -prefix X INPUT+orig
#                      

	
	


	
