#!/usr/bin/python

# filename: preproc_afni.py
# script to do pre-processing of functional data (steps listed below)


import os,sys

# set up study-specific directories and file names, etc.
#data_dir = '/Volumes/blackbox/SA2/data'		# experiment main data directory
data_dir = '/home/hennigan/SA2/data'	
subjects = ['18','19','20','21','23','24','25','26','27','29']  # subjects to process
runs = [1,2,3,4,5,6] 					# scan runs to process


# which pre-processing steps to do? 1 to do, 0 to not do
doSmooth = 1				# smooth data? adds prefix 's'					
doRunMasksAve = 1			# get the average mask across runs for bet
doConvertUnits = 1 			# convert from raw to % change units? adds prefix 'p'
doBet = 1				# brain-extract data?

################# define relevant variables for each pre-processing step as needed

startStr = 'raorun' # reflects pre-processing steps done in preproc1_afni.py

spaceStr = 'tlrc'  # either 'orig' or 'tlrc' to signify space of files

if doSmooth: 
	smooth_mm = 3 						# fwhm gaussian kernel to use for smoothing (in mm)



##########################################################################################
# DO IT


os.chdir(data_dir)
cdir = os.getcwd()
print 'Current working directory: '+cdir


# now loop through subjects, clusters and bricks to get data
for subject in subjects:
	
	print 'WORKING ON SUBJECT '+subject
	
	# define subject's raw & pre-processed directories 
	outDir = data_dir+'/'+subject+'/func_proc/' 

	os.chdir(outDir) 					

	
	for r in runs:
			
		inStr = startStr+str(r)  # file string
		
		
		# smooth
		if doSmooth:
			outStr = 's'+inStr
			cmd = '3dmerge -1blur_fwhm '+str(smooth_mm)+' -doall -prefix '+outStr+' '+inStr+'+'+spaceStr
			print cmd
			os.system(cmd)
			inStr = outStr	# update string to reflect most recent processing step
			
			
		# at this point, make a binary mask of data 
		if doRunMasksAve:		
			cmd = '3dAutomask -prefix mask_run'+str(r)+' '+inStr+'+'+spaceStr
			print cmd
			os.system(cmd)
		
		
		# convert from raw to percent BOLD signal change units
		if doConvertUnits:
			outStr = 'p'+inStr
			cmd = '3dTstat -mean -prefix mean_run'+str(r)+' '+inStr+'+'+spaceStr
			print cmd
			os.system(cmd)
			cmd = '3dcalc -a '+inStr+'+'+spaceStr+' -b mean_run'+str(r)+'+'+spaceStr+" -expr '(a/b)*100' -prefix "+outStr
			print cmd
			os.system(cmd)			
			inStr = outStr	# string signifying the most recent processing step
			
			os.remove('mean_run'+str(r)+'+'+spaceStr+'.BRIK')
			os.remove('mean_run'+str(r)+'+'+spaceStr+'.HEAD')
		
		
		
########### end of run loop
		
	if doBet: 
		
		#base_inStr = 'psraorun'
		base_inStr = inStr[0:len(inStr)-1]  # get input inStr without run #

		cmd = '3dMean -datum float -prefix mean_mask mask_run*'
		print cmd
		os.system(cmd)
		cmd = '3dcalc -datum byte -prefix func_mask -a mean_mask+'+spaceStr+" -expr 'step(a-0.75)'"
		print cmd
		os.system(cmd)
		
		# delete mean mask file
		os.remove('mean_mask+'+spaceStr+'.BRIK.gz')
		os.remove('mean_mask+'+spaceStr+'.HEAD')
		
		for r in runs:
			
			inStr = base_inStr+str(r)
			outStr = 'm'+inStr
			
			cmd = '3dcalc -a '+inStr+'+'+spaceStr+' -b func_mask+'+spaceStr+" -expr 'a*b' -prefix "+outStr
			print cmd
			os.system(cmd)
	
			# delete mask for individual runs
			os.remove('mask_run'+str(r)+'+'+spaceStr+'.BRIK.gz')
			os.remove('mask_run'+str(r)+'+'+spaceStr+'.HEAD')
					
		inStr = outStr	# update string to reflect most recent processing step
		
		
	# finally, rename files to pp_run to signify pre-processing is complete 

	#base_inStr = 'mpsraorun'	
	base_inStr = inStr[0:len(inStr)-1]  # get input inStr without run #
	for r in runs:
		inStr = base_inStr+str(r)	
		outStr = 'pp_run'+str(r)	
		cmd = '3drename '+inStr+'+'+spaceStr+' '+outStr
		print cmd
		os.system(cmd)
		
	
	print 'FINISHED SUBJECT '+subject
			
				
