
#subjects=(CrunchPilot03)
subjects=(ClarkPilot_02)
#preprocessing_steps=("create_vdm")
#preprocessing_steps=("realign_fmri")	
#preprocessing_steps=("slicetime_fmri")
#preprocessing_steps=("coregister_fmri")
#preprocessing_steps=("segment_fmri")
#preprocessing_steps=("skull_strip_t1")
#preprocessing_steps=("n4_bias_correction")
#preprocessing_steps=("ants_norm_fmri")

# # # # preprocessing_steps=(spm_norm_fmri)




# # # TO DO: 
# avoid sending fpm along with vdm to fmri processing folders
# remove the strings for specifying preprocessing steps
# figure out why pwscan is not populating in realign_fmri
# change funtional_imagery_files to functional_files in ML scripts
# determine whether coregister_fmri should use meanUnwarpedRealigned or UnwarpedRealigned
# need a way to determine step was already run (other than processing sheet)
# what is the output of coregister?
# determine where Ugrant_defaults is actually needed
# coregistration and segmentation are not running.. why???
# what is a dilated segmentation?? / ask Kathleen
# consolidate matlab batch files by using data(#)
# try converting img/hdr to nii

module load matlab

# Set the path for our custom matlab functions and scripts
export MATLABPATH=/ufrc/rachaelseidler/tfettrow/Crunch_Code/Matlab_Scripts/helper

for SUB in ${subjects[@]}; do
   	if [[ ${preprocessing_steps[*]} =~ "create_vdm" ]]; then
		data_folder_to_analyze=(Fieldmap_imagery Fieldmap_nback)
	   	for DAT_Folder in ${data_folder_to_analyze[@]}; do
	   		cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/03_Fieldmaps/${DAT_Folder}/
			cp /ufrc/rachaelseidler/tfettrow/Crunch_Code/Matlab_Scripts/helper/Ugrant_defaults.m /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/03_Fieldmaps/${DAT_Folder}/;
			matlab -nodesktop -nosplash -r "try; create_vdm; catch; end; quit"
			if [[ $DAT_Folder == Fieldmap_imagery ]]; then
				cp *img /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/05_MotorImagery/
				cp *hdr /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/05_MotorImagery/
			fi
			if [[ $DAT_Folder == Fieldmap_imagery ]]; then
				cp *img /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/06_Nback/
				cp *hdr /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/06_Nback/
			fi
			rm Ugrant_defaults.m
		done
	fi
	if [[ ${preprocessing_steps[*]} =~ "realign_fmri" ]]; then
		data_folder_to_analyze=(05_MotorImagery 06_Nback)
		for DAT_Folder in ${data_folder_to_analyze[@]}; do
			cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/${DAT_Folder}/
			matlab -nodesktop -nosplash -r "try; realign_fmri; catch; end; quit"
		done
	fi
	if [[ ${preprocessing_steps[*]} =~ "slicetime_fmri" ]]; then
		data_folder_to_analyze=(05_MotorImagery 06_Nback)
		for DAT_Folder in ${data_folder_to_analyze[@]}; do
			cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/${DAT_Folder}/
			matlab -nodesktop -nosplash -r "try; slicetime_fmri; catch; end; quit"
		done
	fi
	if [[ ${preprocessing_steps[*]} =~ "coregister_fmri" ]]; then
		data_folder_to_analyze=(05_MotorImagery 06_Nback)
		for DAT_Folder in ${data_folder_to_analyze[@]}; do
			# need to grab T1 and place into DAT_Folder
			cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/02_T1
			cp T1.nii /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/${DAT_Folder}/

			cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/${DAT_Folder}/
			matlab -nodesktop -nosplash -r "try; coregister_fmri; catch; end; quit"
		done
	fi
	if [[ ${preprocessing_steps[*]} =~ "segment_fmri" ]]; then
		data_folder_to_analyze=(02_T1)
		for DAT_Folder in ${data_folder_to_analyze[@]}; do
			cp /ufrc/rachaelseidler/tfettrow/Crunch_Code/MR_Templates/TPM.nii /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/${DAT_Folder}/
			cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/${DAT_Folder}/
			matlab -nodesktop -nosplash -r "try; segment_fmri; catch; end; quit"
			#rm TPM.nii
		done
	fi
	if [[ ${preprocessing_steps[*]} =~ "skull_strip_t1" ]]; then
		data_folder_to_analyze=(02_T1)
		for DAT_Folder in ${data_folder_to_analyze[@]}; do
			cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/${DAT_Folder}/
			matlab -nodesktop -nosplash -r "try; skull_strip_t1; catch; end; quit"
		done
	fi
	if [[ ${preprocessing_steps[*]} =~ "n4_bias_correction" ]]; then
		data_folder_to_analyze=(02_T1)
		for DAT_Folder in ${data_folder_to_analyze[@]}; do
			ml gcc/5.2.0; ml ants 
			cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/${DAT_Folder}/
			N4BiasFieldCorrection -i SkullStripped_Template.nii -o SkullStripped_biascorrected.nii
		done
	fi
	if [[ ${preprocessing_steps[*]} =~ "ants_norm_fmri" ]]; then
		data_folder_to_analyze=(02_T1)
		for DAT_Folder in ${data_folder_to_analyze[@]}; do
			cd /ufrc/rachaelseidler/tfettrow/Crunch_Code/Shell_Scripts
			cp run_ANTS_MVT.batch /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/${DAT_Folder}/
			cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/${DAT_Folder}/
			sbatch run_ANTS_MVT.batch
			rm run_ANTS_MVT.batch
		done
	fi
done
