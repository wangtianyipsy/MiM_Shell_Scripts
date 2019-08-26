
subjects=(CrunchPilot03)
#subjects=(ClarkPilot_01 ClarkPilot_02)

#preprocessing_steps=("slicetime_fmri")
preprocessing_steps=("merge_fieldmap_fmri")
#preprocessing_steps=("create_vdm_fmri")
#preprocessing_steps=("realign_fmri")
#preprocessing_steps=("apply_vdm_fmri")

#preprocessing_steps=("segment_fmri")
#preprocessing_steps=("skull_strip_t1")

#preprocessing_steps=("coregister_fmri") # this is for 


####preprocessing_steps=("spm_norm_fmri")  # replace the y_T1 with Ants output??
####preprocessing_steps=("smooth_fmri")  # how to decide which norms to smooth?? look for both??


#preprocessing_steps=("art_fmri") # implement in conn


# # # TO DO: 
# what to do with rp_ output files in realign if running realign and realign&unwarp multiple times
# create option to run MVT and ANTSreg locally or batch
# run conn_batch for art
# what is a dilated segmentation??
# find a way to cut down on file path lengths 
# create an ANTS processing_fmri/dwi? .sh
# calculate effective echo spacing ?? see preprocessing steps
# slice timing adjustements (ref middle time, need to be in milliseconds)
# grab subject info from header
# consider removing means after realign and unwarp and use fsl to avg using -Tmean
# create a check in realign for vdm or no / ask user if they want a vdm
# trash the "processed" files in RAW folder (FA, tensor, etc)
# image center function... understand qto and sto .. nifti header info


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
   	if [[ ${preprocessing_steps[*]} =~ "merge_fieldmap_fmri" ]]; then
   		data_folder_to_analyze=(Fieldmap_imagery)
	   	for DAT_Folder in ${data_folder_to_analyze[@]}; do
	   		#Fieldmap_dir=/ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/03_Fieldmaps
			#cd ${Fieldmap_dir}/${DAT_Folder}
			cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/03_Fieldmaps/${DAT_Folder}/
			
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

			ml fsl
			rm AP_PA_merged.nii
			rm se_epi_unwarped
			rm topup_results
			fslmerge -t AP_PA_merged DistMap_AP.nii DistMap_PA.nii
			topup --imain=AP_PA_merged.nii --datain=acqParams.txt --fout=my_fieldmap --config=b02b0.cnf --iout=se_epi_unwarped --out=topup_results
	
			ml fsl/5.0.8
			fslchfiletype ANALYZE my_fieldmap.nii fpm_my_fieldmap
			gunzip *nii.gz*
		done
	fi
	if [[ ${preprocessing_steps[*]} =~ "create_vdm_fmri" ]]; then
		data_folder_to_analyze=(Fieldmap_imagery)
	   	for DAT_Folder in ${data_folder_to_analyze[@]}; do
   			cp /ufrc/rachaelseidler/tfettrow/Crunch_Code/Matlab_Scripts/helper/Ugrant_defaults.m /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/03_Fieldmaps/${DAT_Folder}/
			cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/03_Fieldmaps/${DAT_Folder}/ 
			ml matlab
			matlab -nodesktop -nosplash -r "try; create_vdm; catch; end; quit"

			# needs to be an .img
			if [[ $DAT_Folder == Fieldmap_imagery ]]; then
				#cp vdm5_my_fieldmap.nii /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/05_MotorImagery/
				cp vdm5_fpm_my_fieldmap.hdr /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/05_MotorImagery/
				cp vdm5_fpm_my_fieldmap.img /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/05_MotorImagery/
			fi
			if [[ $DAT_Folder == Fieldmap_nback ]]; then
				#cp vdm5_my_fieldmap.nii /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/06_Nback/
				cp vdm5_fpm_my_fieldmap.hdr /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/06_Nback/
				cp vdm5_fpm_my_fieldmap.img /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/06_Nback/
			fi
			rm Ugrant_defaults.m
		done
	fi

	if [[ ${preprocessing_steps[*]} =~ "coregister_vdm_to_fmri" ]]; then
		data_folder_to_analyze=(05_MotorImagery 06_Nback)
		for DAT_Folder in ${data_folder_to_analyze}[@]}; do
			#cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/03_Fieldmaps/${DAT_Folder}/
			#matlab -nodesktop -nosplash -r "coregister_vdm_to_fmri; quit"
			# need to create this ^^
		done
	fi
	if [[ ${preprocessing_steps[*]} =~ "realign_fmri" ]]; then
		data_folder_to_analyze=(05_MotorImagery 06_Nback)
		for DAT_Folder in ${data_folder_to_analyze[@]}; do
			cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/${DAT_Folder}/
			ml matlab
			matlab -nodesktop -nosplash -r "try; realign_fmri; catch; end; quit"
		done
	fi

	if [[ ${preprocessing_steps[*]} =~ "apply_vdm_fmri" ]]; then
		data_folder_to_analyze=(05_MotorImagery)
		for DAT_Folder in ${data_folder_to_analyze[@]}; do
			cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/${DAT_Folder}/
			ml matlab
			matlab -nodesktop -nosplash -r "try; apply_vdm; catch; end; quit"
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
