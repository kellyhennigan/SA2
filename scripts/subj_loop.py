#!/usr/bin/python

# filename: subj_loop.py
# script to loop over subjects to perform some command



import os,sys



##########################################################################################
# EDIT AS NEEDED:

#data_dir = '/Volumes/blackbox/SA2/data/'		# experiment main data directory
data_dir = '/home/hennigan/SA2/data/'	

subjects = ['9','10','11','12','14','15','16','17','18','19',
	'20','21','23','24','25','26','27','29'] # subjects to process

##########################################################################################


# the idea is to start from the data_dir, which is the parent directory for all the subjects, 
# then input some commands in the terminal which this program will take as input, 
# then have this program perform all those commands on subjects data


print 'From the directory '+data_dir+', this program will cd to each subjects dir, then perform the commands you input now from the command line.'
	
print 'Enter commands to perform *relative to a subjects directory*. Enter "end" after the last command.'

	

cmd_list = []	
cmd = ''
while cmd != 'end':
	cmd_list.append(cmd)
	cmd = input('enter command to perform on each subject: ')
	#print 'the input command was '+cmd

os.chdir(data_dir) 				 # cd to data_dir

# now loop through subjects
for subject in subjects:

	print 'WORKING ON SUBJECT '+subject
	os.chdir(subject)  # cd to subjects dir
	cdir = os.getcwd()
	print 'Current working directory: '+cdir

	for this_cmd in cmd_list:
		os.system(this_cmd)

	os.chdir(data_dir) 				 # cd back to data_dir

	
	

