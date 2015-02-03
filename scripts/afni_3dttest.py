#!/usr/bin/python


# run 1-sample ttests 

import os,sys


# define main directory that has results 
#data_dir = '/Volumes/blackbox/SA2/data/'		# experiment main data directory
data_dir = '/home/hennigan/SA2/data/'	
#data_dir = '/home/kelly/SA2/data/'


res_dir = data_dir+'results_mb/'  # directory containing glm stat files

# specify subjects and scan runs
subjects = ['9','10','11','12','14','15','16','17','18','19','20','21','23','24','25','26','27','29'] # subjects to process


glm_str = '_glm_mb+tlrc'  # identify file string


coeff_idx = 104  # integer indexing the volume of the coefficient within the glm results file
coeff_idx_s17 = 92  # integer indexing the volume of the coefficient within the glm results file

out_str = 'gain_outc'


##########################################################################################


# cd to data dir
os.chdir(data_dir)

subj_files_str = ''

for subject in subjects:
	if subject=='17':
		subj_files_str = subj_files_str + subject+glm_str+"'["+str(coeff_idx_s17)+"]' "
	else:
		subj_files_str = subj_files_str + subject+glm_str+"'["+str(coeff_idx_s17)+"]' "



#print cmd
#os.system(cmd)

cmd1 = '3dttest++ –prefix ' 
print cmd1
os.system(cmd1)

cmd1= out_str+' –setA '
print cmd1
os.system(cmd1)

cmd1=subj_files_str
print cmd1
os.system(cmd1)













	