
subjects=(CrunchPilot02 CrunchPilot03)
#subjects=(ClarkPilot_01 ClarkPilot_02)

#preprocessing_steps=("create_vdm")
#preprocessing_steps=("realign_fmri")
#preprocessing_steps=("create_vdm" "realign_fmri")
#preprocessing_steps=("slicetime_fmri")
#preprocessing_steps=("coregister_fmri")
#preprocessing_steps=("segment_fmri")
#preprocessing_steps=("skull_strip_t1")
#preprocessing_steps=("n4_bias_correction")
#preprocessing_steps=("realign_fmri" "slicetime_fmri" "coregister_fmri" "segment_fmri" "skull_strip_t1" "n4_bias_correction" "spm_norm_fmri")

preprocessing_steps=("ants_norm_fmri")  ## need to work in Ants Registration here...
####preprocessing_steps=("spm_norm_fmri")  
####preprocessing_steps=("smooth_fmri")  # how to decide which norms to smooth?? look for both??
#preprocessing_steps=("art_fmri")


# # # TO DO: 
# rename fsl_fieldmap_correction to fieldmap_fmri
# consider a common script that can call all .sh incuding file_orgnaize and fsl_fieldmap
# avoid sending fpm along with vdm to fmri processing folders
# remove the strings for specifying preprocessing steps
# figure out why pwscan is not populating in realign_fmri
# change funtional_imagery_files to functional_files in ML scripts
# determine whether coregister_fmri should use meanUnwarpedRealigned or UnwarpedRealigned
# need a way to determine step was already run (other than processing sheet)
# coregistration is not running/ what is the output of coregister??
# what is a dilated segmentation?? / ask Kathleen
# consolidate matlab batch files by using data(#)
# try converting img/hdr to nii for pmscan issues
# subject specific template for spm_norm_fmri
# what files should be inside ANTS_processing folder? 
# is there a way to work in n4 and ants registration into MVT.batch? looks like script checks for "helpers"
# ants_norm_fmri is out of order if calling multiple scripts
# is it necessary to ml matlab if some functions are fsl


module load matlab

# Set the path for our custom matlab functions and scripts
export MATLABPATH=/ufrc/rachaelseidler/tfettrow/Crunch_Code/Matlab_Scripts/helper


if [[ ${preprocessing_steps[*]} =~ "ants_norm_fmri" ]]; then
	for SUB in ${subjects[@]}; do
		# need to grab the biascorrected.nii from the subjects of interest
		# move them to the "processing folder" and change file name to include subjectID
		# move .batch to "processing folder" 


		mkdir -p /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/ANTS_Template_Processing_Folder_Crunch
		cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/02_T1/
		cp SkullStripped_biascorrected.nii /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/ANTS_Template_Processing_Folder_Crunch
		
		cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/ANTS_Template_Processing_Folder_Crunch
		mv -v SkullStripped_biascorrected.nii "${SUB}_SkullStripped_biascorrected.nii"		
	done
	cd /ufrc/rachaelseidler/tfettrow/Crunch_Code/Shell_Scripts
	cp run_ANTS_MVT.batch /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/ANTS_Template_Processing_Folder_Crunch
	cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/ANTS_Template_Processing_Folder_Crunch
	sbatch run_ANTS_MVT.batch
	#rm run_ANTS_MVT.batch
fi

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
			

			ml fsl/5.0.8
			fslchfiletype NIFTI *.hdr
			# do this in previous step

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
			rm T1.nii
		done
	fi
	if [[ ${preprocessing_steps[*]} =~ "segment_fmri" ]]; then
		data_folder_to_analyze=(02_T1)
		for DAT_Folder in ${data_folder_to_analyze[@]}; do
			cp /ufrc/rachaelseidler/tfettrow/Crunch_Code/MR_Templates/TPM.nii /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/${DAT_Folder}/
			cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/${DAT_Folder}/
			matlab -nodesktop -nosplash -r "try; segment_fmri; catch; end; quit"
			rm TPM.nii
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
	
	if [[ ${preprocessing_steps[*]} =~ "spm_norm_fmri" ]]; then
		data_folder_to_analyze=(05_MotorImagery 06_Nback)
		for DAT_Folder in ${data_folder_to_analyze[@]}; do
			cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/02_T1
			cp y_T1.nii /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/${DAT_Folder}/

			cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/${DAT_Folder}/
			matlab -nodesktop -nosplash -r "try; spm_norm_fmri; catch; end; quit"
			rm y_T1.nii
		done
	fi
	if [[ ${preprocessing_steps[*]} =~ "smooth_fmri" ]]; then
		data_folder_to_analyze=(05_MotorImagery 06_Nback)
		for DAT_Folder in ${data_folder_to_analyze[@]}; do

			cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/${DAT_Folder}/
			matlab -nodesktop -nosplash -r "try; smooth_fmri; catch; end; quit"
		done
	fi
done

