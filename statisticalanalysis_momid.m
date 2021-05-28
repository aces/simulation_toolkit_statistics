%% August 2019, Mona Omidyeganeh
%
%
% This function evaluates the effect of deformation on CIVET/FS results
% i.e. thicknesses for deformed vs. the unaltered IBIS-Phantom/ICBM datasets
% Supported Versions CIVET: 2.0,2.1.0,2.1.1 and FreeSurfer 5.3 and 6.0
%
% Usage:  sta = statisticalanalysis(pipelinen, csv_filename, meter, sm_fwhm, ptv, ttv, c_centre, roi_right, roi_left, output_folder)
% e.g. sta=statisticalanalysis('CIVET','IBIS_ph_Def40_Size10_Final_ROI4_civet21.csv','tlaplace','0',0.05, 5.3,[65;-15;20],'ROI4_sze10_right.txt','ROI4_size10_left.txt','/results')

%
% NOTE : Four cubic ROIs are selected and the deformation are applied in
%         these areas (in STEROTAXIC space) (top/left/back coordinates)
%            ROI1: Sensory area (x,y,z:w) 11,-11,72
%            ROI2: ACC (x,y,z:w) 8,44,8
%            ROI3: Precuneus (x,y,z:w) -2,-63,35
%            ROI4: Superior Temporal area (x,y,z:w) 65,-16,20
%                  We have also considered an ellipsoid ROI at the same position as ROI5 with size 10x5x5 mm
% NOTE : The unaltered and deformed volumes are available at CBRAIN portal: https://portal.cbrain.mcgill.ca/ in 
%         cortical deformation project.
% NOTE : This function uses SrfStat toolbox:
%            http://www.math.mcgill.ca/keith/surfstat/
% NOTE : Please set and save the folders containing the surface. Sample files and masks and sample CSV files are also %         included.
% NOTE : For your own tests you should provide CSV files similar to the available samples.
%         Two first columns contain the list of the name of measured thickness files for left and right hemispheres.
%         Third column has the information about the unaltered (r0) or deformed (rd) files.
%         Forth column assigns numbers to each MRI scan. 
%
%
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
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Main Function
function sta=statisticalanalysis(pipelinen, csv_filename, meter, sm_fwhm, ptv, ttv, c_centre, roi_right, roi_left,output_folder,roi_size)
close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% STEP 2: Create a sample surface for viewing of the stastical data, Read the midsurface
% and Create a mask for the given ROI (with 1's inside the ROI and 0's at all other vertices)
switch pipelinen
    case 'CIVET'
        s = SurfStatReadSurf({'mid_left.obj','mid_right.obj'});%both left and right together
        s = SurfStatInflate(s , .35 ); %inflated by 25%
        roi_mask=logical(SurfStatReadData({[num2str(roi_left)],[num2str(roi_right)]}));
        
    case 'FS'
        s = SurfStatReadSurf({'lh_mid_fs.obj','rh_mid_fs.obj'});
        roi_mask=SurfStatReadData({[num2str(roi_left)],[num2str(roi_right)]});
        roi_mask(find(roi_mask>0))=1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% STEP 3: Import data from CSV file & store thickness and subject/scanner informations in variables

[Y,subj,defratio,n_orig_scans] = read_CSV_file_info(csv_filename,meter,sm_fwhm,pipelinen);
% Y is a variable containing ALL THE THICKNESS VALUES (N x number of vertices single)
% n_orig_scans: number of the unaltered scans.

N=length(subj);      %Total number of scans included in the analysis
n_unalt = n_orig_scans; %Number of unaltered scans
n_deform = N - n_unalt; %Number of deformed scans
%disp(['N=',num2str(N)]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% STEP 4: Calculate various different average thicknesses...


meanthick = mean (Y(1:n_orig_scans,:)); % Average UNALTERED Thickness Across Whole Brain
stdthick = std (Y(1:n_orig_scans,:)); % standard deviation of UNALTERED Thickness Across Whole Brain
cvthick=stdthick./meanthick; %coefficient of variation of UNALTERED Thickness Across Whole Brain


% Mean and STD and ratio of thickness changes thickness inside/outside the ROI
meanthicksubj_in = mean( double( Y(:, find(roi_mask==1) )), 2 ) ;
meanthicksubj_out = mean( double( Y(:, find(roi_mask==0)) ), 2 ) ;
stdthicksubj_in = std( double( Y(:, find(roi_mask==1) )), 1, 2 ) ;
stdthicksubj_out = std( double( Y(:, find(roi_mask==0)) ),1, 2 ) ;

mthick_in_undef=mean(meanthicksubj_in(1:n_orig_scans));
mthick_in_def=mean(meanthicksubj_in(n_orig_scans+1:end));
mthick_out_undef=mean(meanthicksubj_out(1:n_orig_scans));
mthick_out_def=mean(meanthicksubj_out(n_orig_scans+1:end));

sthick_in_undef=mean(stdthicksubj_in(1:1:n_orig_scans));
sthick_in_def=mean(stdthicksubj_in(n_orig_scans+1:end));
sthick_out_undef=mean(stdthicksubj_out(1:1:n_orig_scans));
sthick_out_def=mean(stdthicksubj_out(n_orig_scans+1:end));

ratio_in=(mthick_in_undef-mthick_in_def)/mthick_in_undef*100;
ratio_out=(mthick_out_undef-mthick_out_def)/mthick_out_undef*100;

% Save the calculated thickness estimation information in 'thickinfo' structure
thickinfo.meanthick=meanthick;
thickinfo.stdthick=stdthick;
thickinfo.cvthick=cvthick;
thickinfo.ratio_in=ratio_in;
thickinfo.ratio_out=ratio_out;
thickinfo.mthick_in_undef=mthick_in_undef;
thickinfo.mthick_in_def=mthick_in_def;
thickinfo.mthick_out_undef=mthick_out_undef;
thickinfo.mthick_out_def=mthick_out_def;
thickinfo.sthick_in_undef=sthick_in_undef;
thickinfo.sthick_in_def=sthick_in_def;
thickinfo.sthick_out_undef=sthick_out_undef;
thickinfo.sthick_out_def=sthick_out_def;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% STEP 5: Define the Model: Pair-Wise comparisons of Deformation Category vs. Unaltered
%                   and Scanner/Subjects
%                   (M = 1 + Defratio + Scanner/Subject)
Defratio = term(defratio);
Subj=(term(var2fac(subj)));
M = 1 +Defratio + Subj; % Define Model M

% Define contrast
contrast =  Defratio.r0 - Defratio.rd;

slm = SurfStatLinMod( Y, M, s ); %Linear model
slm = SurfStatT( slm, contrast); %T-maps
[pval, peak, clus ] = SurfStatP( slm); % Corrected P-values for vertices and clusters.
% Thresholds of random fields
[t_thresh,cl_t,p_t,e_t,e_t_1]= stat_threshold( SurfStatResels(slm), length(slm.t), 1, slm.df );
[a,b]=sort((slm.t),'descend');
b1=b(find(a>=ttv));a1=a(find(a>=ttv));p1=pval.P(b1);
a2=a1(find(p1<=ptv));b2=b1(find(p1<=ptv));c=(s.coord(:,b2));


%Location of ROI...
c1=sqrt(sum((c-c_centre).^2,1));
c_all=(s.coord(:,b));
c1_all=sqrt(sum((c_all-c_centre).^2,1));
p2=pval.P(b2);Y1=Y(:,b1);Y2=Y1(:,find(p1<=ptv));
at=a;a2t=a2;c1t=c1;c1_allt=c1_all;



% Calculated the sensitivity and spesificity
p0=zeros(size(pval.P));fp=0;tp=0;fn=0;tn=0;
for i=1:length(pval.P)
    if ((pval.P(i)<ptv) && (slm.t(i)>ttv))
        p0(i)=1;
    end
    if ((roi_mask(i)==1) && (p0(i)==1))
        tp=tp+1;
    elseif ((roi_mask(i)==1) && (p0(i)==0))
        fn=fn+1;
    elseif ((roi_mask(i)==0) && (p0(i)==0))
        tn=tn+1;
    else
        fp=fp+1;
    end
end
sensitivity=tp/(tp+fn);specificity=tn/(tn+fp);



%Calculate the sensitivity and specificity versus different T-values
ptemp=pval.P(1,find(roi_mask==1));
[a,b]=max(double( slm.t(find(roi_mask==1)) ));
%tvector: a vector containing t-values (0:.5:15) to calculate treshpold index vector;
tvector=0:.5:15;
Tmax=a;
t_in=slm.t(find(roi_mask==1));
t_out=slm.t(find(roi_mask==0));
for t=1:length(tvector)
    tn(t)=length(find(t_out<tvector(t)))/length(t_out);
    tp(t)=length(find(t_in>=tvector(t)))/length(t_in);
    fn(t)=length(find(t_in<tvector(t)))/length(t_in);
    fp(t)=length(find(t_out>=tvector(t)))/length(t_out);
    sens(t)=tp(t)/(tp(t)+fn(t));
    spec(t)=tn(t)/(tn(t)+fp(t));
end
%Threshold index : the maximum value of this index shows the best T-value
ind_t=tp./(fp+fn);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% STEP 6: Plot the results
%plot the ROI
figure,SurfStatView(1.*roi_mask,s,'ROI');set(gca,'FontSize',14);SurfStatColLim( [-1 2] );
saveas(gcf,[num2str(output_folder),'/im1.jpg'])
%plot the mean thickness over the brain (of the unaltered volumes)
figure,SurfStatView( meanthick, s, ['Mean thickness original(mm), n=',num2str(n_orig_scans)] );set(gca,'FontSize',12);SurfStatColLim( [0 7] );
saveas(gcf,[num2str(output_folder),'/im2.jpg'])
%plot the std thickness over the brain (of the unaltered volumes)
figure,SurfStatView( stdthick, s, ['STD thickness original(mm), n=' ,num2str(n_orig_scans)]);set(gca,'FontSize',12);SurfStatColLim( [0 1] );saveas(gcf,[num2str(output_folder),'/im3.jpg'])
%plot the CV thickness over the brain (of the unaltered volumes)
figure,SurfStatView( stdthick./meanthick, s, ['CoV thickness original(mm), n=' ,num2str(n_orig_scans)]);set(gca,'FontSize',12);SurfStatColLim( [0 .5] );saveas(gcf,[num2str(output_folder),'/im4.jpg'])
%plot the model
figure,image (M);set(gca,'FontSize',14);saveas(gcf,[num2str(output_folder),'/im5.jpg'])
%Plot T-map
figure,SurfStatView( slm.t, s, ['T-stat for r0 - rdeformed ', num2str(slm.df),' df)']);SurfStatColLim( [-5 5] );set(gca,'FontSize',10);saveas(gcf,[num2str(output_folder),'/im6.jpg'])
%plot p-map
figure,SurfStatView( pval, s,'P-value' );set(gca,'FontSize',14); saveas(gcf,[num2str(output_folder),'/im7.jpg'])


figure,plot(abs(c1t-roi_size),abs(a2t),'*b',abs(c1_allt-roi_size),abs(at),'.r');hold on;
plot((sqrt(2)*roi_size/2).*ones(1,26),0:25,'-k','LineWidth',3);
text(sqrt(2)*roi_size/2,10,'\leftarrow ROI boundary','FontSize',14);
xlabel('Euclidean distance to the deformation core (mm)');ylabel('T-value');
hold off;xlim([0 40]);ylim([0 25]);set(gca,'FontSize',14);
saveas(gcf,[num2str(output_folder),'/im8.jpg'])
%uncomment to see the true/fals positive/negative plots
%figure,plot(tvector,tp,'*-b',tvector,tn,'^-r',tvector,fp,'s-g',tvector,fn,'+-m',tvector,ind_t,'<-k');set(gca,'FontSize',14);
% %legend('True positive','True negative','False positive','False negative','Threshold index'),xlabel('T-value');%xlim([0 15]);ylim([0 1]);
% figure,plot(tvector,sens,'*-b',tvector,spec,'^-r'),legend('Sensitivity','Specificity'),xlabel('T-value');set(gca,'FontSize',14);%saveas(gcf,[num2str(output_folder),'/im9.jpg'])


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% LAST STEP: Define the output structure: sta
%Evaluation Outputs are saved in an 'sta' struct
sta.sensitivity=sensitivity;sta.specificity=specificity;
sta.sens=sens;sta.spec=spec;sta.tvalvector=tvector;
sta.tn=tn;sta.tp=tp;sta.fn=fn; sta.fp=fp;
sta.ind_t=ind_t;sta.tval=slm.t;sta.pval=pval.P;sta.Tmax=Tmax;
sta.M=M;sta.thickinfo=thickinfo;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Define other functions
% Function to read the data from CSV files and extract thickness estimations
% in a matrix (Y)
function [Y,subj,defratio,n_orig_scans] = read_CSV_file_info(csv_filename,meter,sm_fwhm, pipelinen)
% thickfileleft : list of thickness files of the left hemesphere
% thickfileright : list of thickness files of the right hemesphere
% defratio : The CATEGORY of deformation ratio (i.e. r0, r05, r20, r30 or r40)
% subj: list of the name of the subjects/ scanners

%Inport data from CSV file & store in variables
[thickfileleft, thickfileright, defratio,subj ]= textread(num2str(csv_filename),'%s %s %s %f' );

% Now read the data based on the CSV file and information

n_orig_scans=length(find(strcmp(defratio, 'r0'))); % number of unaltered scans
switch pipelinen
    case 'CIVET'
        thickfileleft=strrep(thickfileleft,'_tlaplace_',['_',num2str(meter),'_']);
        thickfileleft=strrep(thickfileleft,'_0mm_',['_',num2str(sm_fwhm),'mm_']);
        thickfileright=strrep(thickfileright,'_tlaplace_',['_',num2str(meter),'_']);
        thickfileright=strrep(thickfileright,'_0mm_',['_',num2str(sm_fwhm),'mm_']);
    case 'FS'
        thickfileleft=strrep(thickfileleft,'.fwhm0.',['.fwhm',num2str(sm_fwhm),'.']);
        thickfileright=strrep(thickfileright,'.fwhm0.',['.fwhm',num2str(sm_fwhm),'.']);
end
%Import thickness data from each file and store in variable
if n_orig_scans<30
    disp('Reading CSV file...');
    Y = SurfStatReadData( [thickfileleft, thickfileright]);
    Y = abs(double( Y));
else %If number of the subjects/scanners is high it needs to put the data in a temp file to avoid Memory outage
    disp('Reading CSV file...');
    Y = SurfStatReadData( [thickfileleft, thickfileright], '/data1/momidyeganeh/Statistical_Analysis/icbm_tests/icbm_test_feb19/tmp/' );
    A = struct2cell( Y.Data ); Y = abs(double( A{1})');
end
% n_orig_scans: number of the unaltered scans.
% Y is a variable containing ALL THE THICKNESS VALUES (N x number of vertices single)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

