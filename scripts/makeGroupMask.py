#!/usr/bin/python


# make a mean mask from subject masks 

import os,sys


# set up study-specific directories and file names, etc.
#data_dir = '/Volumes/blackbox/SA2/data/'		# experiment main data directory
data_dir = '/home/hennigan/SA2/data/'	
#data_dir = '/home/kelly/SA2/data/'

out_dir = data_dir+'ROIs/'


# specify subjects and scan runs
subjects = ['9','10','11','12','14','15','16','17','18','19','20','21','23','24','25','26','27','29'] # subjects to process
# subjects = ['9','10','11','12','14','15','16','17','18','19','20','21','23','24','25','26','27','28','29'] # subjects to process

##########################################################################################


# cd to out dir
os.chdir(out_dir)

maskPathStr = ''

for subject in subjects:
	maskPathStr = maskPathStr + data_dir+subject+'/func_proc/func_mask+tlrc ' 
	
cmd = '3dMean -datum float -prefix mean_mask '+maskPathStr
os.system(cmd)

cmd = '3dcalc -datum byte -prefix group_mask -a mean_mask+tlrc -expr '"step(a-0.5)"' 
os.system(cmd)





