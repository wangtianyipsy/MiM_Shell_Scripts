# CREATE CSV FOR READING RAW DATA AND NAMING PROCESSE DATA

#################################################################################
# echo Raw_Data_Folder_Name,Processed_Data_Folder_Name,Processed_Data_File_Name,FILE_TYPE(fmri, t1, dwi, asl, restingstate,  or fieldmap) >> ${subject}_file_information.csv

# some things to be careful of:
# 1) no spaces after commas
# 2) If there are multiple functional runs and fieldmaps, number them, and ensure the fieldmap numbers correspond to functioal_run numbers
#################################################################################

# only allows a single subject to be run
subject=CrunchPilot01_development1


cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${subject}
rm ${subject}_file_information.csv 

echo "T1_MPRAGE_SAG_ISO_8MM_0006","02_T1","T1","t1" >> ${subject}_file_information.csv
echo "FMRI-DISTMAP_AP_0015","03_Fieldmaps/Fieldmap_imagery","DistMap_AP","fmri_fieldmap_1" >> ${subject}_file_information.csv
echo "FMRI-DISTMAP_PA_0011","03_Fieldmaps/Fieldmap_imagery","DistMap_PA","fmri_fieldmap_1" >> ${subject}_file_information.csv
echo "FMRI-DISTMAP_AP_0025","03_Fieldmaps/Fieldmap_nback","DistMap_AP","fmri_fieldmap_2" >> ${subject}_file_information.csv
echo "FMRI-DISTMAP_PA_0021","03_Fieldmaps/Fieldmap_nback","DistMap_PA","fmri_fieldmap_2" >> ${subject}_file_information.csv
echo "EP2D_DIFF_5B0_DISTMAP_AP_0043","03_Fieldmaps/Fieldmap_dti","DistMap_AP","dti_fieldmap" >> ${subject}_file_information.csv
echo "EP2D_DIFF_5B0_DISTMAP_PA_FLIPPED_0045","03_Fieldmaps/Fieldmap_dti","DistMap_PA","dti_fieldmap" >> ${subject}_file_information.csv
echo "RESTSTATE-FMRI_8MIN_0009","04_rsfMRI","RestingState","restingstate" >> ${subject}_file_information.csv
echo "FMRI01_RUN1_0017","05_MotorImagery","fMRI_Run1","functional_run_1" >> ${subject}_file_information.csv
echo "FMRI01_RUN2_0019","05_MotorImagery","fMRI_Run2","functional_run_1" >> ${subject}_file_information.csv
echo "FMRI02_RUN1_0027","06_Nback","fMRI_Run1","functional_run_2" >> ${subject}_file_information.csv
echo "FMRI02_RUN2_0029","06_Nback","fMRI_Run2","functional_run_2" >> ${subject}_file_information.csv
echo "FMRI02_RUN3_0031","06_Nback","fMRI_Run3","functional_run_2" >> ${subject}_file_information.csv
echo "FMRI02_RUN4_0033","06_Nback","fMRI_Run4","functional_run_2" >> ${subject}_file_information.csv
echo "ASL_2D_TRA_FULLBRAIN_0035","07_ASL","ASL_Run1","asl" >> ${subject}_file_information.csv
echo "ASL_2D_TRA_FULLBRAIN_0039","07_ASL","ASL_Run2","asl" >> ${subject}_file_information.csv
echo "EP2D_DIFF_5B0_DTI_64DIR_0046","08_DWI","DWI","dwi" >> ${subject}_file_information.csv
