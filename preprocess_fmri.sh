
subjects=(CrunchPilot01_development2)
#subjects=(ClarkPilot_01)

#preprocessing_steps=("slicetime_fmri")
#preprocessing_steps=("merge_distmap_fmri")
#preprocessing_steps=("create_fieldmap_fmri")
#preprocessing_steps=("create_vdm_fmri")
#preprocessing_steps=("coregister_fmri_to_vdm")
#preprocessing_steps=("realign_fmri")
#preprocessing_steps=("realign_unwarp_fmri")
#preprocessing_steps=("apply_vdm_fmri")

#preprocessing_steps=("segment_fmri")
#preprocessing_steps=("skull_strip_t1")

preprocessing_steps=("coregister_fmri_to_T1") # this is for 

#preprocessing_steps=("art_fmri") # implement in conn

# these are currently not being used 
####preprocessing_steps=("spm_norm_fmri")  # replace the y_T1 with Ants output??
####preprocessing_steps=("smooth_fmri")  # how to decide which norms to smooth?? look for both??



# # # TO DO: 
# setup some code, maybe in file_organize to read dicom header info to compare parameters (slice order acq, total readout time, phase encoding) to json file
# rename the raw files to standard names.. dependent on the folder.. create some setup parameters to modify raw_file_dir and new_file_name
# create throw errors in different situations: 1) if file_info.csv not created 2) ...



# Set the path for our custom matlab functions and scripts
Code_dir=/ufrc/rachaelseidler/tfettrow/Crunch_Code


export MATLABPATH=${Code_dir}/Matlab_Scripts/helper


for SUB in ${subjects[@]}; do

Subject_dir=/ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}


	if [[ ${preprocessing_steps[*]} =~ "slicetime_fmri" ]]; then
		data_folder_to_analyze=(05_MotorImagery)
		for DAT_Folder in ${data_folder_to_analyze[@]}; do
			cd ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/
			
			ml matlab
			matlab -nodesktop -nosplash -r "try; slicetime_fmri; catch; end; quit"
		
		done
	fi
   	if [[ ${preprocessing_steps[*]} =~ "merge_distmap_fmri" ]]; then
   		data_folder_to_analyze=(Fieldmap_imagery)
	   	for DAT_Folder in ${data_folder_to_analyze[@]}; do
			cd ${Subject_dir}/Processed/MRI_files/03_Fieldmaps/${DAT_Folder}/
			# just cleaning up in case this is being rerun
			rm AP_PA_merged.nii
			rm Mean_AP_PA_merged.nii
			rm se_epi_unwarped.nii
			rm topup_results_fieldcoef.nii
			rm topup_results_movpar.txt

			ml fsl
			fslmerge -t AP_PA_merged DistMap_AP.nii DistMap_PA.nii

			fslmaths AP_PA_merged -Tmean Mean_AP_PA_merged
			if [[ $DAT_Folder == Fieldmap_imagery ]]; then
				cp Mean_AP_PA_merged.nii ${Subject_dir}/Processed/MRI_files/05_MotorImagery/
			fi
			if [[ $DAT_Folder == Fieldmap_nback ]]; then
				cp Mean_AP_PA_merged.nii ${Subject_dir}/Processed/MRI_files/06_Nback/
			fi
			gunzip *nii.gz*
		done
	fi

	if [[ ${preprocessing_steps[*]} =~ "create_fieldmap_fmri" ]]; then
   		data_folder_to_analyze=(Fieldmap_imagery)
	   	for DAT_Folder in ${data_folder_to_analyze[@]}; do

	   		cd ${Subject_dir}/Processed/MRI_files/03_Fieldmaps/${DAT_Folder}/
	   		# just cleaning up in case this is being rerun
	   		rm my_fieldmap.nii
  			rm acqParams.txt

			# assuming only the DistMaps have .jsons in this folder
			for this_json_file in *.json*; do
									
				total_readout=$(grep "TotalReadoutTime" ${this_json_file} | tr -dc '0.00-9.00')
				encoding_direction=$(grep "PhaseEncodingDirection" ${this_json_file} | cut -d: -f 2 | head -1 | tr -d '"' |  tr -d ',')
				
				this_file_name=$(echo $this_json_file | cut -d. -f 1)
				ml fsl
				this_file_header_info=$(fslhd $this_file_name.nii)
				this_file_number_of_volumes=$(echo $this_file_header_info | grep -o dim4.* | tr -s ' ' | cut -d ' ' -f 2)

				for (( this_volume=1; this_volume<=$this_file_number_of_volumes; this_volume++ )); do
					if [[ $encoding_direction =~ j- ]]; then
						echo 0 -1 0 ${total_readout} >> acqParams.txt
					else
						echo 0 1 0 ${total_readout} >> acqParams.txt
					fi
				done
			done

			ml fsl
			topup --imain=AP_PA_merged.nii --datain=acqParams.txt --fout=my_fieldmap_nifti --config=b02b0.cnf --iout=se_epi_unwarped --out=topup_results
	
			ml fsl/5.0.8
			fslchfiletype ANALYZE my_fieldmap_nifti.nii my_fieldmap

			gunzip *nii.gz*
		done
	fi

	if [[ ${preprocessing_steps[*]} =~ "create_vdm_fmri" ]]; then
		data_folder_to_analyze=(Fieldmap_imagery)
	   	for DAT_Folder in ${data_folder_to_analyze[@]}; do
   			cp ${Code_dir}/Matlab_Scripts/helper/Ugrant_defaults.m ${Subject_dir}/Processed/MRI_files/03_Fieldmaps/${DAT_Folder}/
			cd ${Subject_dir}/Processed/MRI_files/03_Fieldmaps/${DAT_Folder}/ 

			ml matlab
			matlab -nodesktop -nosplash -r "try; create_vdm_img; catch; end; quit"
			matlab -nodesktop -nosplash -r "try; create_vdm_nifti; catch; end; quit"

			# needs to be an .img
			if [[ $DAT_Folder == Fieldmap_imagery ]]; then
				cp vdm5_my_fieldmap.hdr ${Subject_dir}/Processed/MRI_files/05_MotorImagery/
				cp vdm5_my_fieldmap.img ${Subject_dir}/Processed/MRI_files/05_MotorImagery/
			fi
			if [[ $DAT_Folder == Fieldmap_nback ]]; then
				cp vdm5_my_fieldmap.hdr ${Subject_dir}/Processed/MRI_files/06_Nback/
				cp vdm5_my_fieldmap.img ${Subject_dir}/Processed/MRI_files/06_Nback/
			fi
			rm Ugrant_defaults.m
		done
	fi

	if [[ ${preprocessing_steps[*]} =~ "coregister_fmri_to_vdm" ]]; then
		data_folder_to_analyze=(05_MotorImagery)
		for DAT_Folder in ${data_folder_to_analyze[@]}; do
			cd ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/

			ml matlab
			matlab -nodesktop -nosplash -r "try; coregister_fmri_to_vdm; catch; end; quit"
			
		done
	fi

	if [[ ${preprocessing_steps[*]} =~ "realign_fmri" ]]; then
		data_folder_to_analyze=(05_MotorImagery)
		for DAT_Folder in ${data_folder_to_analyze[@]}; do
			cd ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/
			ml matlab
			matlab -nodesktop -nosplash -r "try; realign_fmri; catch; end; quit"
		done
	fi

	if [[ ${preprocessing_steps[*]} =~ "realign_unwarp_fmri" ]]; then
		data_folder_to_analyze=(05_MotorImagery)
		for DAT_Folder in ${data_folder_to_analyze[@]}; do
			cd ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/
			ml matlab
			matlab -nodesktop -nosplash -r "try; realign_unwarp_fmri; catch; end; quit"
			if [[ $DAT_Folder == 05_MotorImagery ]]; then
				# no need for these mean files at the moment.. if necessary we can create later
				rm meanunwarpedRealigned_slicetimed_fMRI01_Run1.nii
				rm meanunwarpedRealigned_slicetimed_fMRI01_Run2.nii
				rm meanunwarpedRealigned_coregistered2vdm_slicetimed_fMRI01_Run1.nii
				rm meanunwarpedRealigned_coregistered2vdm_slicetimed_fMRI01_Run2.nii

				if [[ $DAT_Folder == 05_MotorImagery ]]; then
					mv rp_coregistered2vdm_slicetimed_fMRI01_Run1.txt moveparams_coregistered2vdm_slicetimed_fMRI01_Run1.txt
					mv rp_coregistered2vdm_slicetimed_fMRI01_Run2.txt moveparams_coregistered2vdm_slicetimed_fMRI01_Run2.txt
				fi
				if [[ $DAT_Folder == 06_MotorImagery ]]; then
					mv rp_coregistered2vdm_slicetimed_fMRI01_Run1.txt moveparams_coregistered2vdm_slicetimed_fMRI01_Run1.txt
					mv rp_coregistered2vdm_slicetimed_fMRI01_Run2.txt moveparams_coregistered2vdm_slicetimed_fMRI01_Run2.txt
					mv rp_coregistered2vdm_slicetimed_fMRI01_Run3.txt moveparams_coregistered2vdm_slicetimed_fMRI01_Run3.txt
					mv rp_coregistered2vdm_slicetimed_fMRI01_Run4.txt moveparams_coregistered2vdm_slicetimed_fMRI01_Run4.txt
				fi
			fi
		done
	fi

	if [[ ${preprocessing_steps[*]} =~ "apply_vdm_fmri" ]]; then
		data_folder_to_analyze=(05_MotorImagery)
		for DAT_Folder in ${data_folder_to_analyze[@]}; do
			cd ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/
			ml matlab
			matlab -nodesktop -nosplash -r "try; apply_vdm; catch; end; quit"
			if [[ $DAT_Folder == 05_MotorImagery ]]; then
				rm meanunwarped_realigned_slicetimed_fMRI01_Run1.nii
				rm meanunwarped_realigned_slicetimed_fMRI01_Run2.nii
			fi
		done
	fi

	if [[ ${preprocessing_steps[*]} =~ "segment_fmri" ]]; then
		data_folder_to_analyze=(02_T1)
		for DAT_Folder in ${data_folder_to_analyze[@]}; do
			cp ${Code_dir}/MR_Templates/TPM.nii ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/
			cd ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/
			ml matlab
			matlab -nodesktop -nosplash -r "try; segment_fmri; catch; end; quit"
			rm TPM.nii
		done
	fi

	if [[ ${preprocessing_steps[*]} =~ "skull_strip_t1" ]]; then
		data_folder_to_analyze=(02_T1)
		for DAT_Folder in ${data_folder_to_analyze[@]}; do
			cd ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/
			ml matlab
			matlab -nodesktop -nosplash -r "try; skull_strip_t1; catch; end; quit"
		done
	fi

	if [[ ${preprocessing_steps[*]} =~ "coregister_fmri_to_T1" ]]; then
		data_folder_to_analyze=(05_MotorImagery)
		for DAT_Folder in ${data_folder_to_analyze[@]}; do
			# need to grab T1 and place into DAT_Folder
			cp ${Subject_dir}/Processed/MRI_files/02_T1/SkullStripped_biascorrected.nii ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/

			cd ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/

			ml matlab
			matlab -nodesktop -nosplash -r "try; coregister_fmri_to_t1; catch; end; quit"
			if [[ $DAT_Folder == 05_MotorImagery ]]; then
				cp coregistered2t1_unwarpedRealigned_coregistered2vdm_slicetimed_fMRI01_Run1.nii ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing
				cp coregistered2t1_unwarpedRealigned_coregistered2vdm_slicetimed_fMRI01_Run2.nii ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing
			fi
			rm SkullStripped_biascorrected.nii
		done
	fi
	
	if [[ ${preprocessing_steps[*]} =~ "art_fmri" ]]; then
		data_folder_to_analyze=(05_MotorImagery)
		for DAT_Folder in ${data_folder_to_analyze[@]}; do
			cp ${Subject_dir}/Processed/MRI_files/02_T1/T1.nii ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/

			cd ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/

			ml matlab
			matlab -nodesktop -nosplash -r "try; art_fmri; catch; end; quit"

			rm T1.nii
			rm Conn_Art_Folder_Stuff.mat
			rm -rf Conn_Art_Folder_Stuff
			
		done
	fi

	#if [[ ${preprocessing_steps[*]} =~ "spm_norm_fmri" ]]; then
	#	data_folder_to_analyze=(05_MotorImagery 06_Nback)
	#	for DAT_Folder in ${data_folder_to_analyze[@]}; do
	#		cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/02_T1
	#		cp y_T1.nii /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/${DAT_Folder}/

	#		cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/${DAT_Folder}/
	#		ml matlab
	#		matlab -nodesktop -nosplash -r "try; spm_norm_fmri; catch; end; quit"
	#		rm y_T1.nii
	#	done
	#fi

	if [[ ${preprocessing_steps[*]} =~ "smooth_fmri" ]]; then
		data_folder_to_analyze=(05_MotorImagery 06_Nback)
		for DAT_Folder in ${data_folder_to_analyze[@]}; do

			cd ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/
			ml matlab
			matlab -nodesktop -nosplash -r "try; smooth_fmri; catch; end; quit"
		done
	fi

done
