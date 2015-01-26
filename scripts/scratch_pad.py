#!/usr/bin/python


# scratch pad for python commands

import os,sys,socket


hostname = socket.gethostname()
print "Host name:", hostname

	

# set up study-specific directories and file names, etc.
data_dir = '/Volumes/blackbox/SA2/data/'		# experiment main data directory
#data_dir = '/home/hennigan/SA2/data/'	
ref_file = 'func_ref_vol.nii.gz'  	 		# reference volume filepath (must be in subject's func_proc directory)
mc_str = 'vr_run'							# string for mc_params files
smooth_mm = 3 								# fwhm gaussian kernel to use for smoothing (in mm)


# specify subjects and scan runs
subjects = ['15'] # subjects to process
runs = [3] # scan runs to process


# now loop through subjects, clusters and bricks to get data
os.chdir(data_dir)
#cdir = os.getcwd()
#print 'Current working directory: '+cdir
#os.rename('testfile','../../testfile')

for subject in subjects:

	this_dir = data_dir+'/'+subject+'/'+'raw/' # this subject's data dir
	os.chdir(this_dir)
	cdir = os.getcwd()
	print 'Current working directory: '+cdir
	
	# Open a file
	fo = open("caldisp.1D", "r+")
	lines = fo.readlines()	
	print lines[2]
	position = fo.seek(2,0)
	str = fo.read(10);
	print "Read String is : ", str
	# Close opend file
	fo.close()








