
subjects=(CrunchPilot02 CrunchPilot03)
#subjects=(ClarkPilot_01 ClarkPilot_02)

#preprocessing_steps=("slicetime_fmri")
#preprocessing_steps=("merge_fieldmap_fmri")
#preprocessing_steps=("create_vdm_fmri")
#preprocessing_steps=("realign_fmri")

#preprocessing_steps=("segment_fmri")
#preprocessing_steps=("skull_strip_t1")

#preprocessing_steps=("coregister_fmri") # this is for 

#preprocessing_steps=("n4_bias_correction")


####preprocessing_steps=("spm_norm_fmri")  # replace the y_T1 with Ants output??
####preprocessing_steps=("smooth_fmri")  # how to decide which norms to smooth?? look for both??


#preprocessing_steps=("art_fmri") # implement in conn


# # # TO DO: 
# what to do with rp_ output files in realign if runing realign and realign and unwarp multiple times
# create option to run MVT and ANTSreg locally or batch
# run conn_batch for art
# what is a dilated segmentation??
# find a way to cut down on file path lengths 
# create an ANTS processing_fmri/dwi? .sh
# calculate effective echo spacing ?? see preprocessing steps
# slice timing adjustements (ref middle time, need to be in milliseconds)
# grab subject info from header


# Set the path for our custom matlab functions and scripts
export MATLABPATH=/ufrc/rachaelseidler/tfettrow/Crunch_Code/Matlab_Scripts/helper




for SUB in ${subjects[@]}; do
	if [[ ${preprocessing_steps[*]} =~ "slicetime_fmri" ]]; then
		data_folder_to_analyze=(05_MotorImagery 06_Nback)
		for DAT_Folder in ${data_folder_to_analyze[@]}; do
			cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/${DAT_Folder}/
			ml matlab
			matlab -nodesktop -nosplash -r "try; slicetime_fmri; catch; end; quit"
		done
	fi
   	if [[ ${preprocessing_steps[*]} =~ "merge_fieldmap_fmri" ]]; then
   		data_folder_to_analyze=(Fieldmap_imagery Fieldmap_nback)
	   	for DAT_Folder in ${data_folder_to_analyze[@]}; do
	   		#Fieldmap_dir=/ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/03_Fieldmaps
			#cd ${Fieldmap_dir}/${DAT_Folder}
			cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/03_Fieldmaps/${DAT_Folder}/
			
			ml fsl


			#total read out time? = #Total readout time (FSL) = (MatrixSizePhase - 1) * EffectiveEchoSpacing =  (96 - 1) * .213333 = .0203 sec
			echo 0 -1 0 .0203 >> acqParams.txt
			echo 0  1 0 .0203 >> acqParams.txt


			fslmerge -t AP_PA_merged fMRIDistMapAP.nii fMRIDistMapPA.nii
			topup --imain=AP_PA_merged.nii --datain=acqParams.txt --fout=my_fieldmap --config=b02b0.cnf --iout=se_epi_unwarped --out=topup_results
			

			ml fsl/5.0.8
			fslchfiletype ANALYZE my_fieldmap.nii fpm_my_fieldmap
			gunzip *nii.gz*
	
			#cd ${Fieldmap_dir}/Fieldmap_nback
			#echo 0 -1 0 .0203 >> acqParams_nback.txt 
			#echo 0  1 0 .0203 >> acqParams_nback.txt
			#ml fsl
			#fslmerge -t AP_PA_merged_nback fMRIDistMapAP.nii fMRIDistMapPA.nii
			#topup --imain=AP_PA_merged_nback.nii --datain=acqParams_nback.txt --fout=my_fieldmap_nback --config=b02b0.cnf --iout=se_epi_unwarped_nback --out=topup_results_nback
			#ml fsl/5.0.8
			## convert to hdr
			#fslchfiletype ANALYZE my_fieldmap_nback.nii fpm_my_fieldmap_nback
			##fslmaths se_epi_unwarped_nback -Tmean my_fieldmap_mask_nback
			#gunzip *nii.gz*

		done
	fi
	if [[ ${preprocessing_steps[*]} =~ "create_vdm_fmri" ]]; then
		data_folder_to_analyze=(Fieldmap_imagery Fieldmap_nback)
	   	for DAT_Folder in ${data_folder_to_analyze[@]}; do
   			cp /ufrc/rachaelseidler/tfettrow/Crunch_Code/Matlab_Scripts/helper/Ugrant_defaults.m /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/03_Fieldmaps/${DAT_Folder}/
			cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/03_Fieldmaps/${DAT_Folder}/ 
			ml matlab
			matlab -nodesktop -nosplash -r "try; create_vdm; catch; end; quit"

			# needs to be an .img
			if [[ $DAT_Folder == Fieldmap_imagery ]]; then
				cp vdm5_my_fieldmap.nii /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/05_MotorImagery/
				cp vdm5_fpm_my_fieldmap.hdr /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/05_MotorImagery/
				cp vdm5_fpm_my_fieldmap.img /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/05_MotorImagery/
			fi
			if [[ $DAT_Folder == Fieldmap_nback ]]; then
				cp vdm5_my_fieldmap.nii /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/06_Nback/
				cp vdm5_fpm_my_fieldmap.hdr /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/06_Nback/
				cp vdm5_fpm_my_fieldmap.img /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/06_Nback/
			fi
			rm Ugrant_defaults.m
		done
	fi

	#if [[ ${preprocessing_steps[*]} =~ "coregister_vdm_to_fmri" ]]; then
	#	data_folder_to_analyze=(05_MotorImagery 06_Nback)
	#	for DAT_Folder in ${data_folder_to_analyze}[@]}; do
	#		#cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/03_Fieldmaps/${DAT_Folder}/
	#		#matlab -nodesktop -nosplash -r "coregister_vdm_to_fmri; quit"
	#		# need to create this ^^
	#	done
	#fi
	if [[ ${preprocessing_steps[*]} =~ "realign_fmri" ]]; then
		data_folder_to_analyze=(05_MotorImagery 06_Nback)
		for DAT_Folder in ${data_folder_to_analyze[@]}; do
			cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/${DAT_Folder}/
			ml matlab
			matlab -nodesktop -nosplash -r "try; realign_fmri; catch; end; quit"
		done
	fi
	
	if [[ ${preprocessing_steps[*]} =~ "coregister_fmri" ]]; then
		data_folder_to_analyze=(05_MotorImagery 06_Nback)
		for DAT_Folder in ${data_folder_to_analyze[@]}; do
			# need to grab T1 and place into DAT_Folder
			cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/02_T1
			cp T1.nii /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/${DAT_Folder}/

			cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/${DAT_Folder}/
			ml matlab
			matlab -nodesktop -nosplash -r "try; coregister_fmri; catch; end; quit"
			rm T1.nii
		done
	fi
	if [[ ${preprocessing_steps[*]} =~ "segment_fmri" ]]; then
		data_folder_to_analyze=(02_T1)
		for DAT_Folder in ${data_folder_to_analyze[@]}; do
			cp /ufrc/rachaelseidler/tfettrow/Crunch_Code/MR_Templates/TPM.nii /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/${DAT_Folder}/
			cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/${DAT_Folder}/
			ml matlab
			matlab -nodesktop -nosplash -r "try; segment_fmri; catch; end; quit"
			rm TPM.nii
		done
	fi
	if [[ ${preprocessing_steps[*]} =~ "skull_strip_t1" ]]; then
		data_folder_to_analyze=(02_T1)
		for DAT_Folder in ${data_folder_to_analyze[@]}; do
			cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/${DAT_Folder}/
			ml matlab
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
			ml matlab
			matlab -nodesktop -nosplash -r "try; spm_norm_fmri; catch; end; quit"
			rm y_T1.nii
		done
	fi
	if [[ ${preprocessing_steps[*]} =~ "smooth_fmri" ]]; then
		data_folder_to_analyze=(05_MotorImagery 06_Nback)
		for DAT_Folder in ${data_folder_to_analyze[@]}; do

			cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/${DAT_Folder}/
			ml matlab
			matlab -nodesktop -nosplash -r "try; smooth_fmri; catch; end; quit"
		done
	fi
done
