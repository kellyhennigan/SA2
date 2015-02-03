#!/usr/bin/python

# script to extract some single-subject parameter estimates and perform a simple t-test.
# "infiles" are assumed to contain results from fitting a glm to individual subject data.  

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


# specify subjects and scan runs
#subjects = ['9','10','11','12','14','15','16','17','18','19','20','21','23','24','25','26'] # subjects to process

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


out_sub_labels =  ['gain_win-nothing_T',
'gain+RPE_T',
'gain-RPE_T',
'gainRPE_T',
'gainSPE_T',
'gain_win-nothing_B-S_T',
'gain+RPE_B-S_T',
'gain-RPE_B-S_T',
'gainRPE_B-S_T',
'gainSPE_B-S_T',
'shockcue-neutralcue_T',
'cue_period_T']


out_str = 'GLT_B' # define a string for out files



##########################################################################################


# cd to results dir 
os.chdir(res_dir)

# infiles = glob.glob('*'+in_str+'*')
# for infile in infiles: 
#  		cmd = '3dbucket -prefix '+subject+'_'+out_str+' '+subject+glm_str+"'"+str(idx_17)+"'"


print 'PROCESSING DATA FROM '+len(infiles)+' SUBJECTS...'


for infile in infiles: 
 		cmd = '3dbucket -prefix '+subject+'_'+out_str+' '+subject+glm_str+"'"+str(idx_17)+"'"
# 	else:
# 		cmd = '3dbucket -prefix '+subject+'_'+out_str+' '+subject+glm_str+"'"+str(idx)+"'"
# 	print cmd
# 	os.system(cmd)
# 	
# 	
# 	# change labels in out file
# 	i = 0 # volume counter
# 	for out_label in out_labels:
# 		cmd = '3drefit -sublabel '+str(i)+' '+out_label+' '+subject+'_'+out_str+'+tlrc'
# 		os.system(cmd)
# 		i=i+1
# 	
# 
# 		
# ## to conduct t-tests on GLT_B vols from res_dir as pwd in terminal: 
# 
# 	
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


	
	
	
	3dttest++ -prefix shock-neutral                                        \
          -setA shock-neutral                                          \
             10 "10_glm_wb2+tlrc.HEAD[shockcue-neutralcue_GLT#0_Coef]" \
             11 "11_glm_wb2+tlrc.HEAD[shockcue-neutralcue_GLT#0_Coef]" \
             12 "12_glm_wb2+tlrc.HEAD[shockcue-neutralcue_GLT#0_Coef]" \
             14 "14_glm_wb2+tlrc.HEAD[shockcue-neutralcue_GLT#0_Coef]" \
             15 "15_glm_wb2+tlrc.HEAD[shockcue-neutralcue_GLT#0_Coef]" \
             16 "16_glm_wb2+tlrc.HEAD[shockcue-neutralcue_GLT#0_Coef]" \
             17 "17_glm_wb2+tlrc.HEAD[shockcue-neutralcue_GLT#0_Coef]" \
             18 "18_glm_wb2+tlrc.HEAD[shockcue-neutralcue_GLT#0_Coef]" \
             19 "19_glm_wb2+tlrc.HEAD[shockcue-neutralcue_GLT#0_Coef]" \
             20 "20_glm_wb2+tlrc.HEAD[shockcue-neutralcue_GLT#0_Coef]" \
             21 "21_glm_wb2+tlrc.HEAD[shockcue-neutralcue_GLT#0_Coef]" \
             23 "23_glm_wb2+tlrc.HEAD[shockcue-neutralcue_GLT#0_Coef]" \
             24 "24_glm_wb2+tlrc.HEAD[shockcue-neutralcue_GLT#0_Coef]" \
             25 "25_glm_wb2+tlrc.HEAD[shockcue-neutralcue_GLT#0_Coef]" \
             26 "26_glm_wb2+tlrc.HEAD[shockcue-neutralcue_GLT#0_Coef]" \
             27 "27_glm_wb2+tlrc.HEAD[shockcue-neutralcue_GLT#0_Coef]" \
             29 "29_glm_wb2+tlrc.HEAD[shockcue-neutralcue_GLT#0_Coef]" \
             9 "9_glm_wb2+tlrc.HEAD[shockcue-neutralcue_GLT#0_Coef]"   \


	
	
	


