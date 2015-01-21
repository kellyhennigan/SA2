#!/usr/bin/python

# filename: preproc_afni.py

# simple script to do:
#	motion correction, 
#   smooth data, 
# 	convert from raw to % signal change units,
#   concatenate scan runs, 
# 	make a binary mask of functional data
# 	coregister t2, pd, and t1 anatomical to ref func vol


import os,sys

# set up study-specific directories and file names, etc.
data_dir = '/Volumes/blackbox/SA2/data'


# specify subjects and scan runs
subjects = ['18'] # subjects to process
runs = [1] # scan runs to process
smooth_mm = 3 		# fwhm gaussian kernel to use for smoothing (in mm)


# now loop through subjects, clusters and bricks to get data
for subject in subjects:

	this_dir = data_dir+'/'+subject+'/'+'func_proc/' # this subject's data dir
	ref_file = this_dir+'func_ref_vol.nii.gz'  	 	# reference volume filepath
	
        for r in runs:
        	print r
        	if r==1:
				str1 = '3dAutomask -prefix func_mask +orig'
				print str1
			