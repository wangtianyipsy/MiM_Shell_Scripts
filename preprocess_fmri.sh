
subjects=(CrunchPilot01_development)
#subjects=(ClarkPilot_01)

#preprocessing_steps=("slicetime_fmri")
preprocessing_steps=("merge_distmap_fmri" "create_fieldmap_fmri" "create_vdm_fmri" "coregister_fmri_to_vdm")
#preprocessing_steps=("create_fieldmap_fmri")
#preprocessing_steps=("create_vdm_fmri")
#preprocessing_steps=("coregister_fmri_to_vdm")
#preprocessing_steps=("realign_fmri")
#preprocessing_steps=("realign_unwarp_fmri")
#preprocessing_steps=("apply_vdm_fmri")

#preprocessing_steps=("segment_fmri")
#preprocessing_steps=("skull_strip_t1")

#preprocessing_steps=("coregister_T1_to_fmri") # this is for 

#preprocessing_steps=("art_fmri") # implement in conn

# these are currently not being used 
####preprocessing_steps=("spm_norm_fmri")  # replace the y_T1 with Ants output??
####preprocessing_steps=("smooth_fmri")  # how to decide which norms to smooth?? look for both??



# # # TO DO: 
# find a way to cut down on file path lengths 
# grab subject info from header
# what to do about outliers from art?? how to remove volume?? do it automatically?? if volume removed ... onset time, file nameing ()
# rename rp to full name of resulting file (unwarpedRealigned_slicetimed instead of only slicetimed)
# read phase encoding direction from json
# read number of volumes and send into matlab func (automates dealing with outlier removal and new studies)
# reset origin


# Set the path for our custom matlab functions and scripts
export MATLABPATH=/ufrc/rachaelseidler/tfettrow/Crunch_Code/Matlab_Scripts/helper


for SUB in ${subjects[@]}; do

	if [[ ${preprocessing_steps[*]} =~ "slicetime_fmri" ]]; then
		data_folder_to_analyze=(05_MotorImagery)
		for DAT_Folder in ${data_folder_to_analyze[@]}; do
			cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/${DAT_Folder}/
			ml matlab
			matlab -nodesktop -nosplash -r "try; slicetime_fmri; catch; end; quit"

		done
	fi
   	if [[ ${preprocessing_steps[*]} =~ "merge_distmap_fmri" ]]; then
   		data_folder_to_analyze=(Fieldmap_imagery)
	   	for DAT_Folder in ${data_folder_to_analyze[@]}; do
	   		#Fieldmap_dir=/ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/03_Fieldmaps
			#cd ${Fieldmap_dir}/${DAT_Folder}
			cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/03_Fieldmaps/${DAT_Folder}/

			ml fsl
			rm AP_PA_merged.nii
			rm se_epi_unwarped.nii
			rm topup_results_fieldcoef.nii
			rm topup_results_movpar.txt
			fslmerge -t AP_PA_merged DistMap_AP.nii DistMap_PA.nii

			fslmaths AP_PA_merged -Tmean Mean_AP_PA_merged
			if [[ $DAT_Folder == Fieldmap_imagery ]]; then
				cp Mean_AP_PA_merged.nii /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/05_MotorImagery/
			fi
			if [[ $DAT_Folder == Fieldmap_nback ]]; then
				cp Mean_AP_PA_merged.nii /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/06_Nback/
			fi
			gunzip *nii.gz*
		done
	fi

	if [[ ${preprocessing_steps[*]} =~ "create_fieldmap_fmri" ]]; then
   		data_folder_to_analyze=(Fieldmap_imagery)
	   	for DAT_Folder in ${data_folder_to_analyze[@]}; do

	   		cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/03_Fieldmaps/${DAT_Folder}/
	   		ml fsl

	   		total_readout=$(grep "TotalReadoutTime" DistMap_AP.json | tr -dc '0.00-9.00')

			rm acqParams.txt
			echo 0 -1 0 $total_readout >> acqParams.txt
			echo 0  1 0 $total_readout >> acqParams.txt
		
								
								#for this_json_file in *.json*; do
									
									#total_readout=$(grep "TotalReadoutTime" ${this_json_file} | tr -dc '0.00-9.00')
									#encoding_direction=$(grep "PhaseEncodingDirection" ${this_json_file})
					
									#echo ${total_readout}
									#echo ${encoding_direction}
					
									#if [[ ${encoding_direction} = j- ]]; then
									#	echo "yay!"
									#fi
								
									#echo 0 -1 0 ${total_readout} >> acqParams.txt
									#echo 0  1 0 ${total_readout} >> acqParams.txt
								#done


			topup --imain=AP_PA_merged.nii --datain=acqParams.txt --fout=fpm_my_fieldmap --config=b02b0.cnf --iout=se_epi_unwarped --out=topup_results
	
			#ml fsl/5.0.8
			#fslchfiletype ANALYZE fpm_my_fieldmap.nii img_fpm_my_fieldmap

			#fslmaths se_epi_unwarped -Tmean my_estimated_fieldmap
			#bet2 my_estimated_fieldmap my_estimated_fieldmap_brain -m

			gunzip *nii.gz*
		done
	fi

	if [[ ${preprocessing_steps[*]} =~ "create_vdm_fmri" ]]; then
		data_folder_to_analyze=(Fieldmap_imagery)
	   	for DAT_Folder in ${data_folder_to_analyze[@]}; do
   			cp /ufrc/rachaelseidler/tfettrow/Crunch_Code/Matlab_Scripts/helper/Ugrant_defaults.m /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/03_Fieldmaps/${DAT_Folder}/
			cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/03_Fieldmaps/${DAT_Folder}/ 

			ml matlab
			matlab -nodesktop -nosplash -r "try; create_vdm_img; catch; end; quit"
			matlab -nodesktop -nosplash -r "try; create_vdm_nifti; catch; end; quit"

			# needs to be an .img
			if [[ $DAT_Folder == Fieldmap_imagery ]]; then
				#cp vdm5_fpm_my_fieldmap.nii /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/05_MotorImagery/
				cp vdm5_img_fpm_my_fieldmap.hdr /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/05_MotorImagery/
				cp vdm5_img_fpm_my_fieldmap.img /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/05_MotorImagery/
			fi
			if [[ $DAT_Folder == Fieldmap_nback ]]; then
				#cp vdm5_my_fieldmap.nii /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/06_Nback/
				cp vdm5_fpm_my_fieldmap.hdr /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/06_Nback/
				cp vdm5_fpm_my_fieldmap.img /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/06_Nback/
			fi
			rm Ugrant_defaults.m
		done
	fi

	if [[ ${preprocessing_steps[*]} =~ "coregister_fmri_to_vdm" ]]; then
		data_folder_to_analyze=(05_MotorImagery)
		for DAT_Folder in ${data_folder_to_analyze[@]}; do
			cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/${DAT_Folder}/

			ml matlab
			matlab -nodesktop -nosplash -r "try; coregister_fmri_to_vdm; catch; end; quit"
			
		done
	fi

	if [[ ${preprocessing_steps[*]} =~ "realign_fmri" ]]; then
		data_folder_to_analyze=(05_MotorImagery)
		for DAT_Folder in ${data_folder_to_analyze[@]}; do
			cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/${DAT_Folder}/
			ml matlab
			matlab -nodesktop -nosplash -r "try; realign_fmri; catch; end; quit"
		done
	fi

	if [[ ${preprocessing_steps[*]} =~ "realign_unwarp_fmri" ]]; then
		data_folder_to_analyze=(05_MotorImagery)
		for DAT_Folder in ${data_folder_to_analyze[@]}; do
			cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/${DAT_Folder}/
			ml matlab
			matlab -nodesktop -nosplash -r "try; realign_unwarp_fmri; catch; end; quit"
			if [[ $DAT_Folder == 05_MotorImagery ]]; then
				rm meanunwarpedRealigned_slicetimed_fMRI01_Run1.nii
				rm meanunwarpedRealigned_slicetimed_fMRI01_Run2.nii
				rm meanunwarpedRealigned_coregistered2vdm_slicetimed_fMRI01_Run1.nii
				rm meanunwarpedRealigned_coregistered2vdm_slicetimed_fMRI01_Run2.nii
			fi
		done
	fi

	if [[ ${preprocessing_steps[*]} =~ "apply_vdm_fmri" ]]; then
		data_folder_to_analyze=(05_MotorImagery)
		for DAT_Folder in ${data_folder_to_analyze[@]}; do
			cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/${DAT_Folder}/
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

	if [[ ${preprocessing_steps[*]} =~ "coregister_T1_to_fmri" ]]; then
		data_folder_to_analyze=(05_MotorImagery 06_Nback)
		for DAT_Folder in ${data_folder_to_analyze[@]}; do
			# need to grab T1 and place into DAT_Folder
			cp /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/02_T1/T1.nii /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/${DAT_Folder}/

			cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/${DAT_Folder}/

			if [[ $DAT_Folder == 05_MotorImagery ]]; then
				ml fsl
				rm Mean_unwarpedRealigned_slicetimed_fMRI01_Run1.nii
				rm Mean_unwarpedRealigned_slicetimed_fMRI01_Run2.nii
				fslmaths unwarpedRealigned_slicetimed_fMRI01_Run1.nii -Tmean Mean_unwarpedRealigned_slicetimed_fMRI01_Run1.nii
				fslmaths unwarpedRealigned_slicetimed_fMRI01_Run2.nii -Tmean Mean_unwarpedRealigned_slicetimed_fMRI01_Run2.nii
				gunzip *.nii.gz*
			fi

			ml matlab
			matlab -nodesktop -nosplash -r "try; coregister_fmri; catch; end; quit"
			rm T1.nii
		done
	fi
	
	if [[ ${preprocessing_steps[*]} =~ "art_fmri" ]]; then
		data_folder_to_analyze=(05_MotorImagery)
		for DAT_Folder in ${data_folder_to_analyze[@]}; do
			cp /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/02_T1/T1.nii /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/${DAT_Folder}/

			cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/${DAT_Folder}/

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

			cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/${DAT_Folder}/
			ml matlab
			matlab -nodesktop -nosplash -r "try; smooth_fmri; catch; end; quit"
		done
	fi

done
