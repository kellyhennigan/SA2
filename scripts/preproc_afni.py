#!/usr/bin/python

# filename: preproc_afni.py
# script to do pre-processing of functional data (steps listed below)


import os,sys

# set up study-specific directories and file names, etc.
#data_dir = '/Volumes/blackbox/SA2/data'		# experiment main data directory
data_dir = '/home/hennigan/SA2/data'	
subjects = ['26','27','29'] # subjects to process
runs = [1,2,3,4,5,6] 					# scan runs to process


# which pre-processing steps to do? 1 to do, 0 to not do
doOmit1stVols = 1			# omit 1st volumes from each run? adds prefix 'o'
doCorrectSliceTiming = 1		# correct for slice-timing differences? adds prefix 'a'
doCorrectMotion = 1			# correct for head movement? adds prefix 'r'
doSmooth = 1				# smooth data? adds prefix 's'					
doConvertUnits = 1 			# convert from raw to % change units? adds prefix 'p'
#doConcatRuns = 0  		    	# concatenate all functional runs? calls file pp_all
#doCoreg = 0				# coregister t1 to functional data? adds prefix 'c' to t1 file


# define relevant variables for each pre-processing step as needed
if doOmit1stVols:
	omitNVols = 6   # integer defining the 	# of vols at the beginning of each run to drop
	
if doCorrectSliceTiming:
	st_file = data_dir+'/slice_acq_times'	# file w/ slice acquisition times

if doCorrectMotion: 
	ref_file = 'func_ref_vol.nii.gz'	# reference volume filepath (must be in subject's func_proc directory)
	mc_str = 'vr_run'					# string for mc_params files

if doSmooth: 
	smooth_mm = 3 						# fwhm gaussian kernel to use for smoothing (in mm)


os.chdir(data_dir)
cdir = os.getcwd()
print 'Current working directory: '+cdir

# now loop through subjects, clusters and bricks to get data
for subject in subjects:
	
	print 'WORKING ON SUBJECT '+subject
	
	# define subject's raw & pre-processed directories 
	inDir = data_dir+'/'+subject+'/raw/' 		
	outDir = data_dir+'/'+subject+'/func_proc/' 
	
	for r in runs:
    	# cd to subject's raw directory & define inStr to identify input data file
		os.chdir(inDir) 				
		inStr = 'run'+str(r)
	
		# omit 1st vols?
		if doOmit1stVols:
			outStr = 'o'+inStr
			cmd = '3dTcat -prefix '+outStr+' '+inStr+'.nii.gz['+str(omitNVols)+'..$]'
		else:
			outStr = inStr
			cmd = '3dTcat -prefix '+outStr+' '+inStr+'.nii.gz'
		print cmd
		os.system(cmd)
		inStr = outStr
		
		# mv afni-formatted data to outDir and cd to outDir
		os.rename(inDir+outStr+'+orig.HEAD',outDir+outStr+'+orig.HEAD')
		os.rename(inDir+outStr+'+orig.BRIK',outDir+outStr+'+orig.BRIK')
	 	os.chdir(outDir) 					
		
		# slice time correct
		if doCorrectSliceTiming:
			outStr = 'a'+inStr
			cmd = '3dTshift -verbose -prefix '+outStr+' -tpattern @'+st_file+' '+inStr+'+orig.'
			print cmd
			os.system(cmd)
			inStr = outStr	# update string to reflect most recent processing step
			
		# motion correct
		if doCorrectMotion:
			outStr = 'r'+inStr
			mc_file = mc_str+str(r)+'.1D'	# file name for mc parameters
			cmd = '3dvolreg -verbose -base '+ref_file+' -zpad 4 -1Dfile '+mc_file+' -prefix '+outStr+' '+inStr+'+orig.'
			print cmd
			os.system(cmd)
			inStr = outStr	# update string to reflect most recent processing step
			
			# save out plots of the motion correction params
			cmd = '1dplot -dx 5 -xlabel Time -volreg -png '+mc_str+str(r)+' '+mc_file

			
		# smooth
		if doSmooth:
			outStr = 's'+inStr
			cmd = '3dmerge -1blur_fwhm '+str(smooth_mm)+' -doall -prefix '+outStr+' '+inStr+'+orig'
			print cmd
			os.system(cmd)
			inStr = outStr	# update string to reflect most recent processing step
			
		# if this is the first run, make a binary mask of the smoothed data
		if r==1:
			cmd = '3dAutomask -prefix func_mask '+inStr+'+orig'
			print cmd
			os.system(cmd)
		
		# convert from raw to percent BOLD signal change units
		if doConvertUnits:
			outStr = 'p'+inStr
			cmd = '3dTstat -mean -prefix mean_run'+str(r)+' '+inStr+'+orig; 3dcalc -a '+inStr+'+orig -b mean_run'+str(r)+"+orig -expr '(a/b)*100' -prefix "+outStr
			print cmd
			os.system(cmd)
			inStr = outStr	# string signifying the most recent processing step
			
		os.remove('mean_run'+str(r)+'+orig.BRIK')
		os.remove('mean_run'+str(r)+'+orig.HEAD')
		
	print 'FINISHED SUBJECT '+subject
			
		# update strings of all mc_param files and processed data files
		#mc_files = mc_files+' '+mc_file
		#pp_files = pp_files+' '+inStr+'+orig'
						
# concatenate mc_param files 
#cmd = 'cat '+mc_files+' > '+mc_str+'ALL.1D'
#print cmd
#os.system(cmd)

# save out a plot of all mc_params
#cmd = '1dplot -dx 163 -xlabel Time -volreg -png mparams_fig -pngs 2000 '+mc_str+'ALL.1D'
#print cmd
#os.system(cmd)

# concatenate all runs
#cmd = '3dTcat -prefix pp_all '+pp_files
#print cmd
#os.system(cmd)

# mask out voxels outside the brain
#cmd = "3dcalc -a pp_all+orig. -b func_mask+orig. -expr 'a*b' -prefix pp_all_bet"
#print cmd
#os.system(cmd)
		
