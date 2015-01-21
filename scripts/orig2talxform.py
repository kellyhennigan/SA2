#!/usr/bin/python

# filename: coreg_afni.py
# script to align structural and functional scans to talairach template. 
# structural scans should already be co-registered to functional reference volume.


import os,sys



##########################################################################################
# EDIT AS NEEDED:

#data_dir = '/Volumes/blackbox/SA2/data/'		# experiment main data directory
data_dir = '/home/hennigan/SA2/data/'	

subjects = ['28'] # subjects to process

runs = [1,2,3] # functional runs to normalize

##########################################################################################


# now loop through subjects, clusters and bricks to get data
for subject in subjects:
	
	print 'WORKING ON SUBJECT '+subject

	pp_dir = data_dir+str(subject)+'/func_proc'	 # func_proc dir
	os.chdir(pp_dir) 				 # cd to func_proc directory
	cdir = os.getcwd()
	print 'Current working directory: '+cdir
	

	##### normalize coregistered-t1 to tlrc
	cmd = '@auto_tlrc -base /usr/share/afni/atlases/TT_icbm452+tlrc. -input t1_ns_al+orig. -no_ss'
	os.system(cmd)

	# rename out files 
	cmd = '3drename t1_ns_al+tlrc t1+tlrc'
	os.system(cmd)
	os.rename('t1_ns_al_WarpDrive.log','t1_tlrc_WarpDrive.log')
	os.rename('t1_ns_al.Xaff12.1D','t1_tlrc.Xaff12.1D')
	os.rename('t1_ns_al.Xat.1D','t1_tlrc.Xat.1D')
	

	###### normalize t2 and pd data
	cmd = '@auto_tlrc -apar t1+tlrc. -input pd_ns_al+orig. -dxyz 1.6'
	os.system(cmd)
	cmd = '@auto_tlrc -apar t1+tlrc. -input t2_ns_al+orig. -dxyz 1.6'
	os.system(cmd)
	
	# rename out files 
	cmd = '3drename pd_ns_al+tlrc pd+tlrc'
	os.system(cmd)
	cmd = '3drename t2_ns_al+tlrc t2+tlrc'
	os.system(cmd)
	
	
	###### normalize calibration & func_reference volumes and func_mask
	cmd = '@auto_tlrc -apar t1+tlrc. -input cal_ns_al+orig. -dxyz 1.6'
	os.system(cmd)
	cmd = '@auto_tlrc -apar t1+tlrc. -input func_ref_ns+orig. -dxyz 1.6'
	os.system(cmd)
	cmd = '@auto_tlrc -apar t1+tlrc. -input func_mask+orig. -dxyz 1.6'
	os.system(cmd)
	
	# rename out files 
	cmd = '3drename cal_ns_al+tlrc cal+tlrc'
	os.system(cmd)
	cmd = '3drename func_ref_ns+tlrc func_ref+tlrc'
	os.system(cmd)
	
	
	###### finally, normalize functional data	
	for r in runs:
		cmd = '@auto_tlrc -apar t1+tlrc. -input psraorun'+str(r)+'+orig. -dxyz 1.6'
		os.system(cmd)

		# rename out files 
		cmd = '3drename psraorun'+str(r)+'+tlrc. pp_run'+str(r)+'+tlrc'		
		os.system(cmd)
	
#@auto_tlrc -apar t1+tlrc. -input psraorun4+orig. -dxyz 1.6
#3drename psraorun4+tlrc. pp_run4+tlrc
	

