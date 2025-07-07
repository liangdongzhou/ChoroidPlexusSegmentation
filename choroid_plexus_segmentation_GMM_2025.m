% do the automatic Choroid plexus segmentation using machine learning
% fit distribution using gaussian mixture distribution
% made for BHII projects
% can be applied to FLAIR (recommended) or T1w
% updated on 07-07-2025
% Created by Liangdong Zhou @ Brain Health Imaging Institute in Department of Radiology, Weill Cornell Medicine
% This code is for paper:
%% Region-Informed Machine Learning Model for Choroid Plexus Segmentation in  Alzheimer's Disease
%% by Liangdong  Zhou, et. al, Front. Aging Neurosci. 2025
% Please email: liz2018@med.cornell.edu for any questions or comments

%% Prepre your data to run this code.
% 1. coregister FLAIR and the mask of LV+CP from FreeSurfer into the same space
% 2. make LV+CP from FreeSurfer or other tools left and right individually
% 3. put all of LV+CP_left, LV+CP_right, and T2FLAIR images in the same folder for each subject
% 4. Run this code

clc
clear

subj = dir('Subj'); % list all subjects in the Subj folder
subj(strcmp({subj.name}','.')|strcmp({subj.name}','..')) = [];
N = length(subj);

%% loop for all subjects, each subject takes about 1 to 5 seconds depending on your computational power
for n = 1:N
    tic
    s = subj(n);
    id = s.name;
    disp(id);
    s_dir = fullfile(s.folder,s.name);
	
	% the mask of lateral ventricle + choroid plexus from FreeSurfer should be combined and saved for each side in the subject's individual folder.
    % Note that the segmentation can be performed in FLAIR local space or
    % FreeSurfer T1w space, either way you will need to coregister them
    % into the same space to run this code
    lv_cp_left_dir = fullfile(s_dir,'LV_CP_left.nii.gz'); 
    lv_cp_right_dir = fullfile(s_dir,'LV_CP_right.nii.gz');
    
    %% load left and right lateral ventricle and choroid plexus mask
    lv_left = double(niftiread(lv_cp_left_dir));
    lv_right = double(niftiread(lv_cp_right_dir));
    info = niftiinfo(lv_cp_right_dir);
    info.Datatype = 'single';
    disp([id ' data read..'])
    se = strel('sphere',2);
    
    lv_left_ero = imerode(lv_left,se);
    lv_right_ero = imerode(lv_right,se);

    flr_dir = fullfile(s_dir,'T2FLAIR_brain.nii.gz'); % note that it doesn't matter if FLAIR is brain stripped or not.
    %% load FLAIR image and extract values in LV_CP mask
    flr = double(niftiread(flr_dir));
    flr_left0 = flr.*lv_left_ero;
    flr_right0 = flr.*lv_right_ero;
    flr_left = imgaussfilt3(flr_left0,0.5); % denoise and smoothing
    flr_right = imgaussfilt3(flr_right0,0.5);
    
    flr_left = flr_left./mean(flr_left(flr_left~=0)); % normalization
    flr_right = flr_right./mean(flr_right(flr_right~=0));

    flr_left2 = flr_left(flr_left(:)>0);

    %% set fitting parameters
    S.mu = [0.15 ;1.5; 4]; %  these  parameters can be adjusted according to image data properties
    S.Sigma(:,:,1) = 0.02;
    S.Sigma(:,:,2) = 0.1;
    S.Sigma(:,:,3) = 1.5;
    S.ComponentProportion = [0.45 0.5 0.05];
    reg = 0.01;
    ct = 'full';%'diagonal';
    mi = 2000;
    pt = 1e-6;
    rp = 1;
    sc = false;
    k = 3;
	% this GMM fitting should be done individually each side
    %% fitting for left side
    gmfit = fitgmdist(flr_left2,k,'Start',S,...
        'SharedCovariance',sc,...
        'CovarianceType',ct,...
        'RegularizationValue',reg,...
        'MaxIter',mi,...
        'ProbabilityTolerance',pt,...
        'Replicates',rp); % Fitted GMM
    clusterX_left = cluster(gmfit,flr_left2);
    m_left = [mean(flr_left2(clusterX_left==1)),mean(flr_left2(clusterX_left==2)),mean(flr_left2(clusterX_left==3))];
    [~,idx_left] = max(m_left);

    flr_left(flr_left(:)>0) = clusterX_left;
    flr_left_msk = (flr_left==idx_left);
    
    delete(fullfile(s_dir,'my_CP_left.nii.gz'));
    niftiwrite(single(flr_left_msk),fullfile(s_dir,'GMM_CP_seg_left.nii'),...
        info,'combined',true,'compressed',true);
    disp([id ' left done.'])

    %% fitting for right side
    flr_right2 = flr_right(flr_right(:)>0);
    SharedCovariance = {true};
    gmfit = fitgmdist(flr_right2,k,'Start',S,...
        'SharedCovariance',sc,...
        'CovarianceType',ct,...
        'RegularizationValue',reg,...
        'MaxIter',mi,...
        'ProbabilityTolerance',pt,...
        'Replicates',rp); % Fitted GMM
    clusterX_right = cluster(gmfit,flr_right2);
    m_right = [mean(flr_right2(clusterX_right==1)),mean(flr_right2(clusterX_right==2)),mean(flr_right2(clusterX_right==3))];
    [~,idx_right] = max(m_right);

    flr_right(flr_right(:)>0) = clusterX_right;
    flr_right_msk = (flr_right==idx_right);
    
    niftiwrite(single(flr_right_msk),fullfile(s_dir,'GMM_CP_seg_right.nii'),...
        info,'combined',true,'compressed',true);
    disp([id ' right done.'])
    flr_all_msk = single(flr_right_msk)+single(flr_left_msk);
    niftiwrite(flr_all_msk,fullfile(s_dir,'GMM_CP_seg_all_combined.nii'),...
        info,'combined',true,'compressed',true);
    
    disp([id ' all done.'])
    toc
end
