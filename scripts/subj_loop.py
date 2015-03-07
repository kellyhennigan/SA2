#!/usr/bin/python

# filename: subj_loop.py
# script to loop over subjects to perform some command



import os,sys



##########################################################################################
# EDIT AS NEEDED:

#data_dir = '/Volumes/blackbox/SA2/data/'		# experiment main data directory
# data_dir = '/home/hennigan/SA2/data/'	

# subjects = ['9','10','11','12','14','15','16','17','18','19',
# 	'20','21','23','24','25','26','27','29'] # subjects to process

data_dir = '/Users/Kelly/dti/data'		# experiment main data directory

subjects = ['sa01','sa07','sa10','sa11','sa13','sa14','sa16','sa18',
	'sa19','sa20','sa21','sa22','sa23','sa24','sa25','sa26','sa27',
	'sa28','sa29','sa30','sa31','sa32','sa33','sa34'] # subjects to process

##########################################################################################



print 'Enter desired commands to perform *relative to each subjects directory*.'
print 'Dont worry about cd-ing into the right directory when done.'
print 'Actually, "cd" doesn''t even work, so don''t do it.'
print 'type "end" after the last command.'

os.chdir(data_dir)
os.chdir(subjects[0])
print 'Current working directory: '+os.getcwd()


# now cd to the 1st subject directory and get user input for commands 

cmd_list = []	
cmd = ''
while cmd != 'end':
	cmd_list.append(cmd)
	print 'the input command was '+cmd
	os.system(cmd)
	cmd = raw_input('enter command to perform on each subject: ')
	

del subjects[0] # remove first sub bc commands already executed

	
# now loop through subjects
for subject in subjects:

	print 'WORKING ON SUBJECT '+subject
	os.chdir(data_dir+'/'+subject) # cd to subjects dir
	for cmd in cmd_list:
		os.system(cmd)
		
print 'done'

	
	

