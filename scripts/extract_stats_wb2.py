#!/usr/bin/python

# make a mean mask from subject masks 

import os,sys

# script to extract some stat volumes of interest using afni

# set up study-specific directories and file names, etc.
data_dir = '/Volumes/blackbox/SA2/data/'		# experiment main data directory
#data_dir = '/home/hennigan/SA2/data/'	
#data_dir = '/home/kelly/SA2/data/'

res_dir = data_dir+'results_wb2/'  # directory containing glm stat files


# specify subjects and scan runs
subjects = ['15','16'] # subjects to process
#subjects = ['9','10','11','12','14','17','18','19','20','21','23','24','25','26'] # subjects to process

glm_str = '_glm_wb2+tlrc.'  # identify file string

# integer indexing the volume of the coefficient within the glm results file
idx = [95,98,101,104,107,110,113,116,119,122,125,128] 
idx_17 = [83,86,89,92,95,98,101,104,107,110,113,116]  # different for subj 17



# strings to rename stat vols of interest (should correspond to the idx above)
out_labels = ['gain_win-nothing','gain+RPE','gain-RPE','gainRPE','gainSPE',
'gain_win-nothing_B-S','gain+RPE_B-S','gain-RPE_B-S','gainRPE_B-S','gainSPE_B-S',
'shockcue-neutralcue','cue_period']


out_str = 'GLT_B' # define a string for out files



##########################################################################################


# cd to results dir 
os.chdir(res_dir)

print 'out_labels: '+str(out_labels)


for subject in subjects:

	print 'WORKING ON SUBJECT '+subject

	# extract stats of interest 
	if subject=='17':
		cmd = '3dbucket -prefix '+subject+'_'+out_str+' '+subject+glm_str+"'"+str(idx_17)+"'"
	else:
		cmd = '3dbucket -prefix '+subject+'_'+out_str+' '+subject+glm_str+"'"+str(idx)+"'"
	print cmd
	os.system(cmd)
	
	
	# change labels in out file
	i = 0 # volume counter
	for out_label in out_labels:
		cmd = '3drefit -sublabel '+str(i)+' '+out_label+' '+subject+'_'+out_str+'+tlrc'
		os.system(cmd)
		i=i+1
	

		
## to conduct t-tests on GLT_B vols from res_dir as pwd in terminal: 

	
# 3dttest++ -prefix all_t -brickwise -setA 9_GLT_B+tlrc. 10_GLT_B+tlrc. 11_GLT_B+tlrc. 12_GLT_B+tlrc. 14_GLT_B+tlrc. 17_GLT_B+tlrc. 18_GLT_B+tlrc. 19_GLT_B+tlrc. 20_GLT_B+tlrc. 21_GLT_B+tlrc. 23_GLT_B+tlrc. 24_GLT_B+tlrc. 25_GLT_B+tlrc. 26_GLT_B+tlrc. 
# # 
# # 	


# 'gain_win-nothing','gain+RPE','gain-RPE','gainRPE','gainSPE',
# 'gain_win-nothing_B-S','gain+RPE_B-S','gain-RPE_B-S','gainRPE_B-S','gainSPE_B-S',
# 'shockcue-neutralcue','cue_period'

# 3drefit -sublabel 0 gain_win-nothing_mean all_t+tlrc.
# 3drefit -sublabel 1 gain_win-nothing_T all_t+tlrc.
# 3drefit -sublabel 2 gain+RPE_mean all_t+tlrc.
# 3drefit -sublabel 3 gain+RPE_T all_t+tlrc.
# 3drefit -sublabel 4 gain-RPE_mean all_t+tlrc.
# 3drefit -sublabel 5 gain-RPE_T all_t+tlrc.
# 3drefit -sublabel 6 gainRPE_mean all_t+tlrc.
# 3drefit -sublabel 7 gainRPE_T all_t+tlrc.
# 3drefit -sublabel 8 gainSPE_mean all_t+tlrc.
# 3drefit -sublabel 9 gainSPE_T all_t+tlrc.
# 3drefit -sublabel 10 gain_win-nothing_B-S_mean all_t+tlrc.
# 3drefit -sublabel 11 gain_win-nothing_B-S_T all_t+tlrc.
# 3drefit -sublabel 12 gain+RPE_B-S_mean all_t+tlrc.
# 3drefit -sublabel 13 gain+RPE_B-S_T all_t+tlrc.
# 3drefit -sublabel 14 gain-RPE_B-S_mean all_t+tlrc.
# 3drefit -sublabel 15 gain-RPE_B-S_T all_t+tlrc.
# 3drefit -sublabel 16 gainRPE_B-S_mean all_t+tlrc.
# 3drefit -sublabel 17 gainRPE_B-S_T all_t+tlrc.
# 3drefit -sublabel 18 gainSPE_B-S_mean all_t+tlrc.
# 3drefit -sublabel 19 gainSPE_B-S_T all_t+tlrc.
# 3drefit -sublabel 20 shockcue-neutralcue_mean all_t+tlrc.
# 3drefit -sublabel 21 shockcue-neutralcue_T all_t+tlrc.
# 3drefit -sublabel 22 cue_period_mean all_t+tlrc.
# 3drefit -sublabel 23 cue_period_T all_t+tlrc.


	
	
	
	
	
	
	


