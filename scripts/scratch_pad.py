#!/usr/bin/python


# scratch pad for python commands

import os,sys,socket


hostname = socket.gethostname()
print "Host name:", hostname

	

# set up study-specific directories and file names, etc.
data_dir = '/Volumes/blackbox/SA2/data'		# experiment main data directory
#data_dir = '/home/hennigan/SA2/data'	
ref_file = 'func_ref_vol.nii.gz'  	 		# reference volume filepath (must be in subject's func_proc directory)
mc_str = 'vr_run'							# string for mc_params files
smooth_mm = 3 								# fwhm gaussian kernel to use for smoothing (in mm)


# specify subjects and scan runs
subjects = ['18'] # subjects to process
runs = [3] # scan runs to process


# now loop through subjects, clusters and bricks to get data
os.chdir(data_dir)
cdir = os.getcwd()
print 'Current working directory: '+cdir
#os.rename('testfile','../../testfile')

for subject in subjects:

	this_dir = data_dir+'/'+subject+'/'+'func_proc/' # this subject's data dir
	
	mc_files = ''									 # string of all mc_params files 
	pp_files = '' 									 # string of all pre-processed data files
	
       