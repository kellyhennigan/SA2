#!/usr/bin/python

# filename: subj_loop.py
# script to loop over subjects to perform some command



import os,sys



##########################################################################################
##########################################################################################

	
def printDirections():	
	print 'Enter desired commands to perform *relative to each subjects directory*.'
	print 'Dont worry about cd-ing into the right directory when done.'
	print 'type "end" after the last desired command.'


def whichSubjects():	
	data_dir1 = '/Users/Kelly/dti/data'		# experiment main data directory
	data_dir2 = '/Users/Kelly/SA2/data'		# experiment main data directory

	print '1) '+data_dir1
	print '2) '+data_dir2

	dir_choice = raw_input('which data directory(1 or 2)?')

	if dir_choice==str(1):
		data_dir = data_dir1
		subjects = ['sa01','sa07','sa10','sa11','sa13','sa14','sa16','sa18',
		'sa19','sa20','sa21','sa22','sa23','sa24','sa25','sa26','sa27',
		'sa28','sa29','sa30','sa31','sa32','sa33','sa34'] # subjects to process

	elif dir_choice==str(2):
		data_dir = data_dir2
		subjects = ['9','10','11','12','13','14','15','16','17','18','19',
		'20','21','23','24','25','26','27','28','29','30'] # subjects to process

	return data_dir, subjects


def getSubCommands():
	cmd_list = []	
	cmd = ''
	while cmd != 'end':
		cmd = raw_input('enter command to perform on each subject: ')
		print 'the input command was '+cmd
		cmd_list.append(cmd)
		if cmd.lower()[0:3]=='cd ':
			os.chdir(cmd[3:])
			print 'Current working directory: '+os.getcwd()
		else:
			os.system(cmd)
	return cmd_list
		
		
def performSubCommands(data_dir,subjects,cmd_list):
	for subject in subjects: 		# now loop through subjects
		print 'WORKING ON SUBJECT '+subject
		os.chdir(data_dir+'/'+subject) # cd to subjects dir
		for cmd in cmd_list[0:len(cmd_list)-1]:
			if cmd.lower()[0:3]=='cd ':
				os.chdir(cmd[3:])
			else:
				os.system(cmd)
			
		
def main(): 
	printDirections()						# print directions
	data_dir, subjects = whichSubjects() 	# ask user for data directory
	

	os.chdir(data_dir+'/'+subjects[0]) 		# cd to first subject's dir
	print 'Current working directory: '+os.getcwd()
	
	cmd_list = getSubCommands() 			# have user input commands to perform
	
	print cmd_list
	
	del subjects[0] 			# remove first sub from list bc commands already executed
	
	performSubCommands(data_dir,subjects,cmd_list)  # now perform commands on all subs 
	
	print 'done'


main()