# Simulation-toolkit
A Simulation Toolkit for Testing the Sensitivity and Accuracy of Corticometry Pipelines


August 2019, Mona Omidyeganeh

This function evaluates the effect of deformation on CIVET/FS results
i.e. thicknesses for deformed vs. the unaltered IBIS-Phantom/ICBM datasets
Supported Versions CIVET: 2.0,2.1.0,2.1.1 and FreeSurfer 5.3 and 6.0


NOTE 1: before running code, you must have access to the CIVET_TaskForce_2016 directory thruogh ace_mount in your home directory
NOTE 2: Four cubic ROIs are selected and the deformation are applied in these areas (in STEROTAXIC space) (top/left/back coordinates)
            ROI1: Sensory area (x,y,z:w)
            ROI2: ACC (x,y,z:w)
            ROI3: Precuneus (x,y,z:w)
            ROI4: Superior Temporal area
NOTE 3: This function uses SrfStat toolbox:
            http://www.math.mcgill.ca/keith/surfstat/
NOTE 4: The unaltered and deformed volumes are available at CBRAIN portal: https://portal.cbrain.mcgill.ca/ in cortical deformation project.

The resulting subtle, localized changes in the cortex in the four ROIs used in the present work is shown in videos which can be accessed on the GitHub repository:
https://github.com/aces/Simulation-toolkit/tree/monaomid-Sample-Videos-of-ROIs


Here is the description of how to use the simulation fuction is Matlab:

This function evaluates the effect of deformation on CIVET/FS results, i.e. thicknesses for deformed vs. the unaltered IBIS-Phantom/ICBM datasets
Supported Versions CIVET: 2.0,2.1.0,2.1.1 and FreeSurfer 5.3 and 6.0

Usage:  sta = sta_june19_momid_v2(pipelinen, csv_filename, meter, sm_fwhm, ptv, ttv, c_centre, roi_right, roi_left, output_folder)
e.g. sta=sta_june19_momid_v2('CIVET','IBIS_ph_Def40_Size10_Final_ROI4_civet21.csv','tlaplace','0',0.05, 5.3,[65;15;20],'ROI4_size10_right.txt','ROI4_size10_left.txt','/data1/momidyeganeh/Statistical_Analysis/sta_matlab_momid/results')


NOTE : Four cubic ROIs are selected and the deformation are applied in
        these areas (in STEROTAXIC space) (top/left/back coordinates)
            ROI1: Sensory area (x,y,z:w) 11,-11,72
            ROI2: ACC (x,y,z:w) 8,44,8
            ROI3: Precuneus (x,y,z:w) -2,-63,35
            ROI4: Superior Temporal area (x,y,z:w) 65,-16,20
NOTE : Please set phat and save the folders containing the surface samples and masks and CSV files (available at CBRAIN portal: https://portal.cbrain.mcgill.ca/ in cortical deformation project).

% Inputs:
%      pipelinen     =  which neuroimaging pipeline 'CIVET' or 'FS'
%      csv_filename =  .CSV file name that contains th einformation of thickness
%                      file names and subjects and deformation data.
%      meter        =  define the thickness measurement method 
%                      for CIVET: 'tlink', 'tlaplace' or 'tfs'
%                          FS   : 'fsaverage'
%      sm_fwhm      =  smothing kernel  '0' '5' '10' '15' '20' mm
%      ttv          =  T threshold value- Default - 5.3
%      ptv          =  P value threshold- Default - 0.05
%  
%      These inputs will be asked from user:
%      roi_num      =  The ID of the roi where the deformation is applied(1,2,3
%                      or 4)- Default - ROI4
%      size_roi     =  The size of applied deformation (5 or 10 mm)- Default - size 10
%      ratio_def    =  The deformation ratio applies (5, 20, 30 or 40 % change
%                      in the volume)- Default - 40%
%      meter        =  The thickness metric to be used in current analysis (for
%                      CIVET: tlink, tfs, tlaplace, for FS: faverage)- Default - tlaplace
%      sm_fwhm      =  Smoothing kernel size (0,5,10,15,20,25 mm)- Default - 0mm
%      dataname     =  Name of the dataset 'IBIS_ph' or 'ICBM'- Default -IBIS_ph
%      pipelinen    =  The name of the pipeline to evaluate (FS/CIVET)- Default - CIVET
%      c_centre     =  The deformation core
%                       ROI1:  c_centre=[11;-11;72];
%                       ROI2:  c_centre=[8;44;8];
%                       ROI3:  c_centre=[-2;-63;35];
%                       ROI4:  c_centre=[65;-15;20];
%      roi_right    ,
%      roi_left     = Define ROI masks image on the mid surface, you can
%                     use your own ROI or the available ROIS:
%                           CIVET : roi_left=['ROI',num2str(roi_num),'_size',num2str(size_roi),'_left.txt']
%                                   roi_right=['ROI',num2str(roi_num),'_size',num2str(size_roi),'_right.txt']
%                           FS    : roi_left=['ROI',num2str(roi_num),'_size',num2str(size_roi),'_left_FS.txt']
%                                   roi_right=['ROI',num2str(roi_num),'_size',num2str(size_roi),'_right_FS.txt']
%                           roi_num=1,2,3,4 and size_roi=5,10 
%     output_folder = define the folder to save resulted figures
%     roi_size      = 5mm or 10mm 
%
% Outputs:
%   sta: a structure that contains all following information this structure contains:
%
%      sta.sensitivity =  Sensitivity value (calculated based on defined thresholds for T and p)
%      sta.specificity =  Specificity value (calculated based on defined thresholds for T and p)
%      sta.sens        =  Sensitivity value (calculated at different Tvalue Thresholds (Tval_vector))
%      sta.spec        =  Specificity value (calculated at different Tvalue Thresholds (Tval_vector))
%      sta.tvalvector  =  vector of different Tvalue Thresholds 
%      sta.tn          =  True negatives at different Tvalue Thresholds (Tval_vector)
%      sta.tp          =  True positives at different Tvalue Thresholds (Tval_vector)
%      sta.fn          =  False negatives at different Tvalue Thresholds (Tval_vector)
%      sta.fp          =  False positives at different Tvalue Thresholds (Tval_vector)
%      sta.ind_t       =  Threshold index vector
%      sta.Tmax        =  Maximum T-value
%      sta.M           =  Defined Model
%      sta.tval        =  T-values across the entire brain
%      sta.pval        =  P-values acroess the entire brain
%      sta.thickinfo   =  thickinfo is a structure containing all calculated
%
%      Information about thickness and its changes (unaltered vs. deformed)
%         thickinfo.meanthick        =  Average UNALTERED Thickness Across Whole Brain
%         thickinfo.stdthick         =  STD of UNALTERED Thickness Across Whole Brain
%         thickinfo.cvthick          =  Coefficient of variation ofUNALTERED Thickness Across Whole Brain
%         thickinfo.ratio_in         =  Ratio change in thickness inside ROI(deformed vs. unaltered)
%         thickinfo.ratio_out        =  Ratio change in thickness outside ROI(deformed vs. unaltered)
%         thickinfo.mthick_in_undef  =  Average UNALTERED Thickness Inside ROI
%         thickinfo.mthick_in_def    =  Average DEFORMED Thickness Inside ROI
%         thickinfo.mthick_out_undef =  Average DEFORMED Thickness outside ROI
%         thickinfo.mthick_out_def   =  Average DEFORMED Thickness outside ROI
%         thickinfo.sthick_in_undef  =  STD UNALTERED Thickness Inside ROI
%         thickinfo.sthick_in_def    =  STD DEFORMED Thickness Inside ROI
%         thickinfo.sthick_out_undef =  STD UNALTERED Thickness outside ROI
%         thickinfo.sthick_out_def   =  STD DEFORMED Thickness outside ROI

