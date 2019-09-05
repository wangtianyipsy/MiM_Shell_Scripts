subjects=(CrunchPilot03)
data_folder_to_analyze=(05_MotorImagery)
file_to_compare_1='pEPI_unwarpedRealigned_slicetimed_fMRI01_Run1.nii'
file_to_compare_2='P_unwarpedRealigned_slicetimed_fMRI01_Run1.nii'
#volume=1
export MATLABPATH=/ufrc/rachaelseidler/tfettrow/Crunch_Code/Matlab_Scripts/helper
		
cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/$subjects/Processed/MRI_files/$data_folder_to_analyze
ml fsl
fslmaths $file_to_compare_1 -sub $file_to_compare_2 imdiff_EPIcheck

gunzip *.nii.gz*
