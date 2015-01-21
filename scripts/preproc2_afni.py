#!/usr/bin/python

# filename: preproc2_afni.py
# script to continue pre-processing data after running script, preproc_afni.py

# check the following: 

# concatenate and plot motion parameters - 
# is there a big difference between runs 1-3 and 4-6? 
# if so, for those subjects, re-process from motion correction stage 
# using -twopass -twodup options on 3dvolreg for runs 4-6

# check out the binary mask - does it look ok? 
# if so, concatenate runs 1-6 and use the mask to zero out non-brain voxels



import os,sys

# set up study-specific directories and file names, etc.
data_dir = '/home/hennigan/SA2/data/'	
subjects = ['10','11','12'] # subjects to process

##### commands to run: # 
# cat vr_run1.1D  vr_run2.1D  vr_run3.1D  vr_run4.1D  vr_run5.1D vr_run6.1D > vr_ALL.1D
# 1dplot -dx 163 -xlabel Time -volreg -png vr_ALL vr_ALL.1D
# 
# 1dplot -dx 5 -xlabel Time -volreg -png vr_run1 vr_run1.1D
# 1dplot -dx 5 -xlabel Time -volreg -png vr_run2 vr_run2.1D
# 1dplot -dx 5 -xlabel Time -volreg -png vr_run3 vr_run3.1D
# 1dplot -dx 5 -xlabel Time -volreg -png vr_run4 vr_run4.1D
# 1dplot -dx 5 -xlabel Time -volreg -png vr_run5 vr_run5.1D
# 1dplot -dx 5 -xlabel Time -volreg -png vr_run6 vr_run6.1D
# 

all_mc_str = 'vr_ALL' 				
all_data_str = 'pp_ALL'


##########################################################################################


# now loop through subjects, clusters and bricks to get data
for subject in subjects:

	pp_dir = data_dir+subject+'/func_proc/' # this subject's pre-proc dir


	os.chdir(pp_dir) 				# cd to subject's func_proc directory
	cdir = os.getcwd()
	print 'Current working directory: '+cdir

    									
	# concatenate mc_param files 
	cmd = 'cat vr_run1.1D  vr_run2.1D  vr_run3.1D  vr_run4.1D  vr_run5.1D vr_run6.1D > '+all_mc_str+'.1D'
	os.system(cmd)

	# save out a plot of all mc_params
	cmd = '1dplot -dx 163 -xlabel Time -volreg -png '+all_mc_str+' '+all_mc_str+'.1D'
	os.system(cmd)


	# concatenate all runs
	cmd = '3dTcat -prefix '+all_data_str+' psraorun1+orig. psraorun2+orig. psraorun3+orig. psraorun4+orig. psraorun5+orig. psraorun6+orig.'
	print cmd
	os.system(cmd)

	# bet concatenated runs
	cmd = '3dAutomask -apply_prefix '+all_data_str+'_bet '+all_data_str+'+orig.'
	print cmd
	os.system(cmd)



		
