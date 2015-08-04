#!/usr/bin/python

# script to extract some single-subject parameter estimates and perform a simple t-test.
# "infiles" are assumed to contain results from fitting a glm to individual subject data.  

# Infile names should be in the form of: *_in_str, where * is a 
# specific subject id that will be included in the out file. 

# sub_labels provides the labels of the volumes to be extracted from the infiles, and 
# corresponding t-stats in outfiles will be named according to out_sub_labels.

import os,sys,re,glob


# set up study-specific directories and file names, etc.
#data_dir = '/Volumes/blackbox/SA2/data/'		# experiment main data directory
data_dir = '/home/hennigan/SA2/data/'	
#data_dir = '/home/kelly/SA2/data/'

res_dir = data_dir+'results_wb/'  # directory containing glm stat files


in_str = '_glm+tlrc.HEAD'  # identify file string

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

	
out_str = 'GLT_coeff'   # string to include in single subject files 
out_str_t = 'all_t' # string for t-test results file 
##########################################################################################


os.chdir(res_dir) 		 			# cd to results dir 

infiles = glob.glob('*'+in_str) 	# find infiles 
print 'found '+str(len(infiles))+' files to process...'

for infile in infiles: 

	subj = infile.replace(in_str,'',1)  # cool way to extract subject id string
	print 'working on subject '+subj

	cmd = '3dbucket -prefix '+subj+'_'+out_str+' '+infile+'['+','.join(sub_labels)+']'
	print cmd
	os.system(cmd)


# conduct a t-test on all extracted volumes
cmd = "3dttest++ -prefix "+out_str_t+" -brickwise -setA '*"+out_str+"+tlrc.HEAD'"

#cmd = "3dttest++ -prefix "+out_str_t+" -brickwise -mask ../ROIs_tlrc/DA_bin_mask.nii.gz -setA '*"+out_str+"+tlrc.HEAD'"
print cmd
os.system(cmd)


i = 0  # sub label counter
for out_sub_label in out_sub_labels:
	cmd = '3drefit -sublabel '+str(i)+' '+out_sub_label+'_coeff '+out_str_t+'+tlrc'
	print cmd 
	os.system(cmd)
	i=i+1
	cmd = '3drefit -sublabel '+str(i)+' '+out_sub_label+'_T '+out_str_t+'+tlrc'
	print cmd 
	os.system(cmd)
	i=i+1	
	
	
# 3drefit -sublabel 0 gain_win-nothing_mean all_t_learners+tlrc.
# 3drefit -sublabel 1 gain_win-nothing_T all_t_learners+tlrc.
# 
# 3drefit -sublabel 2 gain+RPE_mean all_t_learners+tlrc.
# 3drefit -sublabel 3 gain+RPE_T all_t_learners+tlrc.
# 3drefit -sublabel 4 gain-RPE_mean all_t_learners+tlrc.
# 3drefit -sublabel 5 gain-RPE_T all_t_learners+tlrc.
# 3drefit -sublabel 6 gainRPE_mean all_t_learners+tlrc.
# 3drefit -sublabel 7 gainRPE_T all_t_learners+tlrc.
# 3drefit -sublabel 8 gainSPE_mean all_t_learners+tlrc.
# 3drefit -sublabel 9 gainSPE_T all_t_learners+tlrc.
# 3drefit -sublabel 10 gain_win-nothing_B-S_mean all_t_learners+tlrc.
# 3drefit -sublabel 11 gain_win-nothing_B-S_T all_t_learners+tlrc.
# 3drefit -sublabel 12 gain+RPE_B-S_mean all_t_learners+tlrc.
# 3drefit -sublabel 13 gain+RPE_B-S_T all_t_learners+tlrc.
# 3drefit -sublabel 14 gain-RPE_B-S_mean all_t_learners+tlrc.
# 3drefit -sublabel 15 gain-RPE_B-S_T all_t_learners+tlrc.
# 3drefit -sublabel 16 gainRPE_B-S_mean all_t_learners+tlrc.
# 3drefit -sublabel 17 gainRPE_B-S_T all_t_learners+tlrc.
# 3drefit -sublabel 18 gainSPE_B-S_mean all_t_learners+tlrc.
# 3drefit -sublabel 19 gainSPE_B-S_T all_t_learners+tlrc.
# 3drefit -sublabel 20 shockcue-neutralcue_mean all_t_learners+tlrc.
# 3drefit -sublabel 21 shockcue-neutralcue_T all_t_learners+tlrc.
# 3drefit -sublabel 22 cue_period_mean all_t_learners+tlrc.
# 3drefit -sublabel 23 cue_period_T all_t_learners+tlrc.

	
	
	


