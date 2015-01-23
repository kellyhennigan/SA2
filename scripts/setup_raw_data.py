#!/usr/bin/python

# filename: setup_raw_data.py
# script to set up a subject's data folder and to create symbolic links to raw data


import os,sys

# define study-specific directories and file names, etc.

nims_exp_dir = '/nimsfs/smcclure/SA2/'		# experiment main dir on nims
data_dir = '/home/hennigan/SA2/data/'		# main data dir 


subject = '30'								# subject id (string)
exam_no = '8313'							# cni exam number (string)
nims_exam_dir = '20141103_1550_8313/'		# string IDing the subject's data directory on nims


# define the scan numbers associated with each scan: 
func_runs=[7,9,0,0,0,0]  # should correspond to runs 1,2,3,4,5,6, respectively 
t1=3
t2pd=10
dti=12
fmaps=[5,0,0,0] 	# should correspond to fieldmaps 1,2,3,4, respectively
cal_scan1 = 9 		 # scan number corresponding to the calibration scan run before functional run 1 
cal_scan4 = 18 		 # scan number corresponding to the calibration scan run before functional run 4



# 30	11/3/2014	8313	20141103_1550_8313	7	9	-	-	-	-	3	10	12	5	-	-	-


#############

# define subject's directory on nims
subj_nims_dir = nims_exp_dir+nims_exam_dir 	# define subject exam directory on nims


# make subject directories if not already made 
subject_dir=data_dir+subject
if not os.path.exists(subject_dir):
    os.makedirs(subject_dir)
raw_dir=subject_dir+'/raw/'
if not os.path.exists(raw_dir):
    os.makedirs(raw_dir)
pp_dir=subject_dir+'/func_proc/'
if not os.path.exists(pp_dir):
    os.makedirs(pp_dir)

# cd to subject's raw data dir    
os.chdir(raw_dir)


################## CREATE SYMBOLIC LINKS TO NIMS DATA ##################

# functional data & physio data
run_num = 1
for r in func_runs:
	if r!=0:
		#  runX fmri data
		filePath = subj_nims_dir+exam_no+'_'+str(r)+'_1_mux3_16mm_TR15_DEV/'+exam_no+'_'+str(r)+'_1.nii.gz'
		if os.path.exists(filePath):
			cmd = 'ln -s '+filePath+' run'+str(run_num)+'.nii.gz'
			os.system(cmd)	

		# runX physio
		filePath = subj_nims_dir+exam_no+'_'+str(r)+'_1_mux3_16mm_TR15_DEV/'+exam_no+'_'+str(r)+'_1_physio.tgz'
		if os.path.exists(filePath):
			cmd = 'ln -s '+filePath+' physio_run'+str(run_num)+'.tgz'
			os.system(cmd)	
		
		# runX physio regs
		filePath = subj_nims_dir+exam_no+'_'+str(r)+'_1_mux3_16mm_TR15_DEV/'+exam_no+'_'+str(r)+'_1_physio_regressors.csv.gz'
		if os.path.exists(filePath):
			cmd = 'ln -s '+filePath+' physio_regs_run'+str(run_num)+'.csv.gz'
			os.system(cmd)	

	run_num = run_num+1
	
	
# t1 data
if t1!=0:
	filePath = subj_nims_dir+exam_no+'_'+str(t1)+'_1_T1w_9mm_sag/'+exam_no+'_'+str(t1)+'_1.nii.gz'
	if os.path.exists(filePath):
		cmd = 'ln -s '+filePath+' t1.nii.gz'
		os.system(cmd)	
		
		
# t2pd data
if t2pd!=0:
	filePath = subj_nims_dir+exam_no+'_'+str(t2pd)+'_1_2D_T2wPDw_FSE/'+exam_no+'_'+str(t2pd)+'_1.nii.gz'
	if os.path.exists(filePath):
		cmd = 'ln -s '+filePath+' t2pd.nii.gz'
		os.system(cmd)	


# dti data
if dti!=0:
	filePath = subj_nims_dir+exam_no+'_'+str(dti)+'_1_DTI_2mm_b2000_80dir/'+exam_no+'_'+str(dti)+'_1.nii.gz'
	if os.path.exists(filePath):
		cmd = 'ln -s '+filePath+' dwi.nii.gz'
		os.system(cmd)	

	filePath = subj_nims_dir+exam_no+'_'+str(dti)+'_1_DTI_2mm_b2000_80dir/'+exam_no+'_'+str(dti)+'_1.bval'
	if os.path.exists(filePath):
		cmd = 'ln -s '+filePath+' dwi.bval'
		os.system(cmd)	

	filePath = subj_nims_dir+exam_no+'_'+str(dti)+'_1_DTI_2mm_b2000_80dir/'+exam_no+'_'+str(dti)+'_1.bvec'
	if os.path.exists(filePath):
		cmd = 'ln -s '+filePath+' dwi.bvec'
		os.system(cmd)	


# fieldmap data
fmap_num = 1
for r in fmaps:
	if r!=0:
		filePath = subj_nims_dir+exam_no+'_'+str(r)+'_1_spiral_fieldmap/'+exam_no+'_'+str(r)+'_1_B0.nii.gz'
		if os.path.exists(filePath):
			cmd = 'ln -s '+filePath+' fmap'+str(fmap_num)+'_B0.nii.gz'
			os.system(cmd)	
		
		filePath = subj_nims_dir+exam_no+'_'+str(r)+'_1_spiral_fieldmap/'+exam_no+'_'+str(r)+'_1.nii.gz'
		if os.path.exists(filePath):
			cmd = 'ln -s '+filePath+' fmap'+str(fmap_num)+'.nii.gz'
			os.system(cmd)	

	fmap_num = fmap_num+1
	
	
# calibration scans
filePath = subj_nims_dir+exam_no+'_'+str(cal_scan1)+'_1_mux3_cal_DEV/'+exam_no+'_'+str(cal_scan1)+'_1.nii.gz'
	if os.path.exists(filePath):
		cmd = 'ln -s '+filePath+' cal_run1.nii.gz'
		os.system(cmd)	
		
filePath = subj_nims_dir+exam_no+'_'+str(cal_scan4)+'_1_mux3_cal_DEV/'+exam_no+'_'+str(cal_scan4)+'_1.nii.gz'
	if os.path.exists(filePath):
		cmd = 'ln -s '+filePath+' cal_run4.nii.gz'
		os.system(cmd)	
	


# create a functional reference volume nifti using the 7th vol of the first run 
# (after dropping 1st vols this will be the 1st vol) 
cmd = "nifti_tool -cbl -prefix func_ref_vol.nii.gz -infiles run1.nii.gz[6]"
os.system(cmd)	
os.rename(raw_dir+'func_ref_vol.nii.gz',pp_dir+'func_ref_vol.nii.gz') # move func_ref_vol to subject's pp_dir


# create a 2nd functional reference volume nifti using the 7th vol of the fourth run 
# (after dropping 1st vols this will be the 1st vol) 
cmd = "nifti_tool -cbl -prefix run4_vol1.nii.gz -infiles run4.nii.gz[6]"
os.system(cmd)	
os.rename(raw_dir+'run4_vol1.nii.gz',pp_dir+'run4_vol1.nii.gz') # move func_ref_vol to subject's pp_dir


# separate the t2w and pd volumes 
cmd = "nifti_tool -cbl -prefix t2.nii.gz -infiles t2pd.nii.gz[0]"
os.system(cmd)	
cmd = "nifti_tool -cbl -prefix pd.nii.gz -infiles t2pd.nii.gz[1]"
os.system(cmd)	


# create a reference volume from the 2nd volume of calibrations scans 1 and 4
cmd = "nifti_tool -cbl -prefix cal_run1_v2.nii.gz -infiles cal_run1.nii.gz[1]"
os.system(cmd)	
cmd = "nifti_tool -cbl -prefix cal_run4_v2.nii.gz -infiles cal_run4.nii.gz[1]"
os.system(cmd)			

