#!/usr/bin/python


# extract a time series averaged across voxels within an ROI mask

import os,sys


# set up study-specific directories and file names, etc.
data_dir = '/Volumes/blackbox/SA2/data/'		# experiment main data directory
#data_dir = '/home/hennigan/SA2/data/'	
#data_dir = '/home/kelly/SA2/data/'

roi_mask_path = data_dir+'ROIs/ventricle_mask.nii.gz'


# specify subjects and scan runs
#subjects = ['9','10','11','12','14','15','16','17','18','19','20','21','23','24','25','26','27','29'] # subjects to process
subjects = ['17']


data_files = ['pp_run1+tlrc.','pp_run2+tlrc.','pp_run3+tlrc.','pp_run4+tlrc.','pp_run5+tlrc.','pp_run6+tlrc.']

out_file = 'ventricle_ts'  # name for text file w/ROI time series s

##########################################################################################



for subject in subjects:

	print 'WORKING ON SUBJECT '+subject

	ts_dir = data_dir+subject+'/func_proc'
	os.chdir(ts_dir)
	
	if os.path.isfile(out_file):
		print 'script stopped because out_file '+out_file+' already exists - maybe you want to rename the out_file?'
	else:
		cmd = 'touch '+out_file
		os.system(cmd)
		
		for data_file in data_files:
			cmd = '3dmaskave -mask '+roi_mask_path+' -quiet '+data_file+' >> '+out_file
			os.system(cmd)
		




