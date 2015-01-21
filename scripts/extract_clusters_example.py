#!/usr/bin/python

# filename: extract_clusters.py
# from here: http://brainimaging.waisman.wisc.edu/~tjohnstone/AFNI_I.html
# simple script to cycle through 6 subjects and extract the cluster means from 4 designated clusters and two conditions
# means are first appended to a temporary text file, with subject number, cluster number, and condition brick
# appended to a separate temporary text file. The two files are then combined using 1dcat to give a properly indexed
# file which could be imported into a stats package or spreadsheet program

import os,sys

# set up study-specific directories and file names
top_dir = '/study/my_study/analysis/'
cluster_mask_file = top_dir+'group_by_face_clust_order+tlrc'
subject_stats_filename = 'glm_out_5mm+tlrc'
output_file = top_dir+'clust_means.txt'


# specify the subjects, clusters and bricks that you want to extract
subjects = ['001','002','004','008','009','010'] # these are the subjects (should be same as subject directory names)
clusters = [2,5,6,8] # these are the cluster numbers that we want to extract
condition_bricks = [4,6] # these are the bricks in the individual subject data files that contain the conditions of interest

# check to see for existence of temporary files
if os.isfile('tmp.txt') or os.isfile('tmp2.txt'):
        print 'You first need to delete or rename the file(s) tmp.txt and tmp2.txt'
        sys.exit()

# check to see for existence of output file
if os.isfile(output_file):
        print 'You first need to delete or rename the output file '+output_file
        sys.exit()


# now loop through subjects, clusters and bricks to get data
for subject in subjects:
        for cluster in clusters:
                for brick in condition_bricks:
                        subject_dir = top_dir+subject+'/'
                        data_file = subject_dir+subject_stats_filename+'['+str(brick)+']'
                        command = '3dmaskave –mask '+cluster_mask_file+' -mrange '+str(cluster)+' '+str(cluster)+' '+data_file+' >> tmp.txt'
                        print command
                        os.system(command)
                        command = 'echo '+subject+' '+str(cluster)+' '+str(brick)+' >> tmp2.txt'
                        print command
                        os.system(command)

# create the output file with appropriate column headings
command  = 'echo subject cluster brick contrast > '+output_file
print command
os.system(command)

# now combine the two temporary file and then delete them
command  = '1dcat tmp2.txt tmp.txt[0] >> '+output_file
print command
os.system(command)

os.remove('tmp.txt')
os.remove('tmp2.txt')