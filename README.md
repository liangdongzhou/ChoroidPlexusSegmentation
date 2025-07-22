# This code aims to do the automatic Choroid plexus segmentation using machine learning by fitting distribution of T2FLAIR image into gaussian mixture distribution

Input data: This code can be applied to FLAIR (recommended) or T1w.

Updated on 07-07-2025

Created by Liangdong Zhou @ Brain Health Imaging Institute in Department of Radiology, Weill Cornell Medicine

* [This code is for paper: Region-Informed Machine Learning Model for Choroid Plexus Segmentation in  Alzheimer's Disease](https://www.frontiersin.org/journals/aging-neuroscience/articles/10.3389/fnagi.2025.1613320)
by Liangdong  Zhou, et. al, Front. Aging Neurosci. 2025

Please email: liz2018@med.cornell.edu for any questions or comments

# Prepre your data to run this code.
1. Coregister FLAIR and the mask of LV+CP from FreeSurfer into the same space (eg. FreeSurfer space)
2. Make left and right LV+CP from FreeSurfer or other tools, since the segmentation will be done side by side
3. Put all of LV+CP_left (LV_CP_left.nii.gz), LV+CP_right (LV_CP_left.nii.gz), and T2FLAIR (T2FLAIR_brain.nii.gz) images in the same folder for each subject
4. Run this code

# Suggested data/code structure
```
--Code
--Subj_dir
----Subj1
        LV_CP_left.nii.gz
        LV_CP_Right.nii.gz
        T2FLAIR_brain.nii.gz
----Subj2
        LV_CP_left.nii.gz
        LV_CP_Right.nii.gz
        T2FLAIR_brain.nii.gz
```
