Aim: This code help to do the automatic Choroid plexus segmentation using machine learning by fitting distribution of T2FLAIR image in gaussian mixture distribution
Input data: This code can be applied to FLAIR (recommended) or T1w.
Updated on 07-07-2025
Created by Liangdong Zhou @ Brain Health Imaging Institute in Department of Radiology, Weill Cornell Medicine

* [This code is for paper: Region-Informed Machine Learning Model for Choroid Plexus Segmentation in  Alzheimer's Disease](https://www.frontiersin.org/journals/aging-neuroscience/articles/10.3389/fnagi.2025.1613320)
by Liangdong  Zhou, et. al, Front. Aging Neurosci. 2025
Please email: liz2018@med.cornell.edu for any questions or comments

# Prepre your data to run this code.
1. coregister FLAIR and the mask of LV+CP from FreeSurfer into the same space
2. make LV+CP from FreeSurfer or other tools left and right individually
3. put all of LV+CP_left, LV+CP_right, and T2FLAIR images in the same folder for each subject
4. Run this code
