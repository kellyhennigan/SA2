#!/usr/bin/python

# script to extract some single-subject parameter estimates and perform a simple t-test.
# looks for stats files using the in_str +wildcard and performs one sample t-tests on the 
# volumes identified based on sub_labels.

# Infile names should be in the form of: *_in_str, where * is a 
# specific subject id that will be included in the out file. 

# sub_labels provides the labels of the volumes to be extracted from the infiles, and 
# corresponding t-stats in outfiles will be named according to out_sub_labels.


import os,sys,glob


# set up study-specific directories and file names, etc.
data_dir = '/Volumes/blackbox/SA2/data/'		# experiment main data directory
#data_dir = '/home/hennigan/SA2/data/'	
#data_dir = '/home/kelly/SA2/data/'

res_dir = data_dir+'results_wb2/'  # directory containing glm stat files


in_str = '_glm_wb2+tlrc.HEAD'  # identify file string

sub_labels = ['gain_win-nothing_GLT#0_Coef',
'gain+RPE_GLT#0_Coef',
'gain-RPE_GLT#0_Coef',
'gainRPE_GLT#0_Coef',
'gainSPE_GLT#0_Coef',
'gain_win-nothing_B-S_GLT#0_Coef',
'gain+RPE_B-S_GLT#0_Coef',
'gain-RPE_B-S_GLT#0_Coef',
'gainRPE_B-S_GLT#0_Coef',
'gainSPE_B-S_GLT#0_Coef',
'shockcue-neutralcue_GLT#0_Coef',
'cue_period_GLT#0_Coef']


out_sub_labels =  ['gain_win-nothing',
'gain+RPE',
'gain-RPE',
'gainRPE',
'gainSPE',
'gain_win-nothing_B-S',
'gain+RPE_B-S',
'gain-RPE_B-S',
'gainRPE_B-S',
'gainSPE_B-S',
'shockcue-neutralcue',
'cue_period']


out_str = 'all_t' # define a string for out files



##########################################################################################


# cd to results dir 
os.chdir(res_dir)


cmd = "3dttest++ -setA '*"+in_str+sub_labels+"' -prefix "+out_str+" -mask group_mask.nii"
os.system(cmd)


