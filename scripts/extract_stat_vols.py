#!/usr/bin/python

# make a mean mask from subject masks 

import os,sys

# script to extract some stat volumes of interest using afni

# set up study-specific directories and file names, etc.
#data_dir = '/Volumes/blackbox/SA2/data/'		# experiment main data directory
#data_dir = '/home/hennigan/SA2/data/'	
data_dir = '/home/kelly/SA2/data/'

res_dir = data_dir+'results_mb2/'  # directory containing glm stat files


# specify subjects and scan runs
subjects = ['9','10','11','12','14','15','16','17','18','19','20','21','23','24','25','26','27','29'] # subjects to process


glm_str = '_glm_mb2+tlrc.'  # identify file string

# integer indexing the volume of the coefficient within the glm results file
idx = [95,98,101,104,107,110,131,134] 
idx_17 = [83,86,89,92,95,98,119,122]  # different for subj 17


# strings to rename stat vols of interest (should correspond to the idx above)
out_labels = ['gain_outc','gain_outc_base-stress',
	'gain_PE','gain_PE_base-stress',
	'gain_sPE','gain_sPE_base-stress',
	'shockcue-neutralcue','cue_period']
	
out_str = 'GLT_B' # define a string for out files


write_out_T = 1  # if true/1, a t-stat volumes will be saved as well (NOTE: its assumed
#  that the t-stat files come right after the coeffs of interest, so this will take the 
# vols idx+1

out_t_str = 'GLT_T'  # only used if write_out_T==true

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
	

####### write out t stats as a separate file? 	
if write_out_T==1:	

	t_idx = [x+1 for x in idx]
	t_idx_17 = [x+1 for x in idx_17]
	
	for subject in subjects:

		print 'WORKING ON T VOLS for SUBJECT '+subject

		# extract stats of interest 
		if subject=='17':
			cmd = '3dbucket -prefix '+subject+'_'+out_t_str+' '+subject+glm_str+"'"+str(t_idx_17)+"'"
		else:
			cmd = '3dbucket -prefix '+subject+'_'+out_t_str+' '+subject+glm_str+"'"+str(t_idx)+"'"
		print cmd
		os.system(cmd)
	
	
		# change labels in out file
		i = 0 # volume counter
		for out_label in out_labels:
			cmd = '3drefit -sublabel '+str(i)+' '+out_label+'_T '+subject+'_'+out_t_str+'+tlrc'
			os.system(cmd)
			i=i+1
	
	
	
	
## to conduct t-tests on GLT_B vols from res_dir as pwd in terminal: 

	
# 3dttest++ -prefix all_t -brickwise -setA 9_GLT_B+tlrc. 10_GLT_B+tlrc. 11_GLT_B+tlrc. 12_GLT_B+tlrc. 14_GLT_B+tlrc. 15_GLT_B+tlrc. 16_GLT_B+tlrc. 17_GLT_B+tlrc. 18_GLT_B+tlrc. 19_GLT_B+tlrc. 20_GLT_B+tlrc. 21_GLT_B+tlrc. 23_GLT_B+tlrc. 24_GLT_B+tlrc. 25_GLT_B+tlrc. 26_GLT_B+tlrc. 27_GLT_B+tlrc. 29_GLT_B+tlrc. 
# 
# 	
# 3drefit -sublabel 0 gain_outc_mean all_t+tlrc.
# 3drefit -sublabel 1 gain_outc_tstat all_t+tlrc.
# 3drefit -sublabel 2 gain_outc_base-stress_mean all_t+tlrc.
# 3drefit -sublabel 3 gain_outc_base-stress_tstat all_t+tlrc.
# 3drefit -sublabel 4 gain_PE_mean_tstat all_t+tlrc.
# 3drefit -sublabel 5 gain_PE_tstat all_t+tlrc.
# 3drefit -sublabel 6 gain_PE_base-stress_mean all_t+tlrc.
# 3drefit -sublabel 7 gain_PE_base-stress_tstat all_t+tlrc.
# 3drefit -sublabel 8 gain_sPE_mean_tstat all_t+tlrc.
# 3drefit -sublabel 9 gain_sPE_tstat all_t+tlrc.
# 3drefit -sublabel 10 gain_sPE_base-stress_mean all_t+tlrc.
# 3drefit -sublabel 11 gain_sPE_base-stress_tstat all_t+tlrc.
# 3drefit -sublabel 12 shockcue-neutralcue_mean all_t+tlrc.
# 3drefit -sublabel 13 shockcue-neutralcue_tstat all_t+tlrc.
# 3drefit -sublabel 14 cue_period_mean all_t+tlrc.
# 3drefit -sublabel 15 cue_period_tstat all_t+tlrc.


	
	
	
	
	
	
	


