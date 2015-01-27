#!/usr/bin/python


# scratch pad for python commands

import os,sys

	

# set up study-specific directories and file names, etc.
#data_dir = '/Volumes/blackbox/SA2/data/'		# experiment main data directory
#data_dir = '/home/hennigan/SA2/data/'	
data_dir = '/home/kelly/SA2/data/'



# specify subjects and scan runs
subjects = ['9','10','11','12','14','15','16','17','18','19','20','21','23','24','25','26','27','28','29'] # subjects to process
# subjects = ['9','10','11','12','14','15','16','17','18','19','20','21','23','24','25','26','27','28','29'] # subjects to process


# cd to data dir
os.chdir(data_dir)
#cdir = os.getcwd()
#print 'Current working directory: '+cdir


for subject in subjects:

	print 'WORKING ON SUBJECT '+subject
	
	this_dir = data_dir+subject+'/'+'results/' # this subject's data dir
	os.chdir(this_dir)
	
	cmd = 'cp * ../../results'
	os.system(cmd)
	
	
	
	# Open a file
# 	fo = open("caldisp.1D", "r+")
# 	lines = fo.readlines()	
# 	print lines[2]
# 	position = fo.seek(2,0)
# 	str = fo.read(10);
# 	print "Read String is : ", str
# 	# Close opend file
# 	fo.close()








