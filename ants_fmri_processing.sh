	
subjects=(CrunchPilot02)
#subjects=(ClarkPilot_01 ClarkPilot_02)


#ants_processing_steps=("ants_create_MVT")
#ants_processing_steps=("ants_registration_Func_2_MNI")
#ants_processing_steps=("ants_registration_Func_2_T1")
ants_processing_steps=("ants_apply_transform")

# # # TO DO: 
# create option to run MVT and ANTSreg locally or batch
# what is a dilated segmentation??
# to do implement 06_Nback
# implement multiple runs
# shorten file paths (create groupAnts_dir and subectAnts_dir)
# Func -> T1 -> MVT -> MNI  
# adjust MVT file output name to Sub_T1_to_MVT


for SUB in ${subjects[@]}; do
	if [[ ${ants_processing_steps[*]} =~ "ants_registration_Func_2_T1" ]]; then
		data_folder_to_analyze=(05_MotorImagery)
		for DAT_Folder in ${data_folder_to_analyze[@]}; do

			Subject_dir=/ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/

			# Create folders
			mkdir -p ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing

			ml gcc/5.2.0
			ml ants
			
			outputFolder=${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing
			Mean_Func=${Subject_dir}/Processed/MRI_files/${DAT_Folder}/meanunwarpedRealigned_slicetimed_fMRI01Run1.nii
			T1_Template=${Subject_dir}/Processed/MRI_files/02_T1/SkullStripped_biascorrected.nii
			
			antsRegistration --dimensionality 3 --float 0 \
			        --output [$outputFolder/Func_to_T1_,$outputFolder/Func_to_T1_Warped.nii.gz] \
			        --interpolation Linear \
			        --winsorize-image-intensities [0.005,0.995] \
			        --use-histogram-matching 0 \
			        --initial-moving-transform [$Mean_Func,$T1_Template,1] \
			        --transform Rigid[0.1] \
			        --metric MI[$Mean_Func,$T1_Template,1,32,Regular,0.25] \
			        --convergence [1000x500x250x100,1e-6,10] \
			        --shrink-factors 8x4x2x1 \
			        --smoothing-sigmas 3x2x1x0vox \
			        --transform Affine[0.1] \
			        --metric MI[$Mean_Func,$T1_Template,1,32,Regular,0.25] \
			        --convergence [1000x500x250x100,1e-6,10] \
			        --shrink-factors 8x4x2x1 \
			        --smoothing-sigmas 3x2x1x0vox \
			        --transform SyN[0.1,3,0] \
			        --metric CC[$Mean_Func,$T1_Template,1,4] \
			        --convergence [100x70x50x20,1e-6,10] \
			        --shrink-factors 8x4x2x1 \
			        --smoothing-sigmas 3x2x1x0vox
		done
	fi
	if [[ ${ants_processing_steps[*]} =~ "ants_registration_Func_2_MNI" ]]; then
		data_folder_to_analyze=(05_MotorImagery)
		for DAT_Folder in ${data_folder_to_analyze[@]}; do

			Subject_dir=/ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/

			# Create folders
			mkdir -p ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing

			ml gcc/5.2.0
			ml ants
			
			outputFolder=${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing
			Mean_Func=${Subject_dir}/Processed/MRI_files/${DAT_Folder}/meanunwarpedRealigned_slicetimed_fMRI01Run1.nii
			MNI_Template=/ufrc/rachaelseidler/tfettrow/Crunch_Code/MR_Templates/_ANTs_c0cTemplate_T1_IXI555_MNI152_GS_brain.nii
			
			antsRegistration --dimensionality 3 --float 0 \
			        --output [$outputFolder/Func_to_MNI_,$outputFolder/Func_to_MNI_Warped.nii.gz] \
			        --interpolation Linear \
			        --winsorize-image-intensities [0.005,0.995] \
			        --use-histogram-matching 0 \
			        --initial-moving-transform [$Mean_Func,$MNI_Template,1] \
			        --transform Rigid[0.1] \
			        --metric MI[$Mean_Func,$MNI_Template,1,32,Regular,0.25] \
			        --convergence [1000x500x250x100,1e-6,10] \
			        --shrink-factors 8x4x2x1 \
			        --smoothing-sigmas 3x2x1x0vox \
			        --transform Affine[0.1] \
			        --metric MI[$Mean_Func,$MNI_Template,1,32,Regular,0.25] \
			        --convergence [1000x500x250x100,1e-6,10] \
			        --shrink-factors 8x4x2x1 \
			        --smoothing-sigmas 3x2x1x0vox \
			        --transform SyN[0.1,3,0] \
			        --metric CC[$Mean_Func,$MNI_Template,1,4] \
			        --convergence [100x70x50x20,1e-6,10] \
			        --shrink-factors 8x4x2x1 \
			        --smoothing-sigmas 3x2x1x0vox
		done
	fi
	if [[ ${ants_processing_steps[*]} =~ "ants_apply_transform" ]]; then
		data_folder_to_analyze=(05_MotorImagery)
		for DAT_Folder in ${data_folder_to_analyze[@]}; do
			Subject_dir=/ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/
			Ants_dir=/ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/ANTS_Template_Processing_Folder_Crunch/

			cp /ufrc/rachaelseidler/tfettrow/Crunch_Code/MR_Templates/_ANTs_c0cTemplate_T1_IXI555_MNI152_GS_brain.nii ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing
			cp ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/unwarpedRealigned_slicetimed_fMRI01Run1.nii ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing
			cp ${Ants_dir}/MVT_to_MNI_0GenericAffine.mat ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing
			cp ${Ants_dir}/MVT_to_MNI_1InverseWarp.nii.gz ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing
			cp ${Ants_dir}/MVT_to_MNI_1Warp.nii.gz ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing
			cp ${Ants_dir}/MVT_to_MNI_Warped.nii.gz ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing
			cp ${Ants_dir}/multivariate_CrunchPilot02_SkullStripped_biascorrected01Warp.nii.gz ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing
			cp ${Ants_dir}/multivariate_CrunchPilot02_SkullStripped_biascorrected01InverseWarp.nii.gz ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing
			cp ${Ants_dir}/multivariate_CrunchPilot02_SkullStripped_biascorrected00GenericAffine.mat ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing

			cd ${Subject_dir}//Processed/MRI_files/${DAT_Folder}/ANTS_Processing

			ml gcc/5.2.0; ml ants
			antsApplyTransforms -d 3 -e 3 -i unwarpedRealigned_slicetimed_fMRI01Run1.nii -r _ANTs_c0cTemplate_T1_IXI555_MNI152_GS_brain.nii \
			-n BSpline -o unwarpedRealigned_slicetimed_warpedToMNI.nii.gz -t [MVT_to_MNI_1Warp.nii.gz] -t [MVT_to_MNI_0GenericAffine.mat,0] \
			-t [multivariate_CrunchPilot02_SkullStripped_biascorrected01Warp.nii.gz] -t [multivariate_CrunchPilot02_SkullStripped_biascorrected00GenericAffine.mat,0] \
			-t [Func_to_T1_1Warp.nii.gz] -t [Func_to_T1_0GenericAffine.mat,0] -v 
		done
	fi
done

if [[ ${ants_processing_steps[*]} =~ "ants_create_MVT" ]]; then
	for SUB in ${subjects[@]}; do
		# need to grab the biascorrected.nii from the subjects of interest
		# move them to the "processing folder" and change file name to include subjectID
		# move .batch to "processing folder" 


		mkdir -p /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/ANTS_Template_Processing_Folder_Crunch_Batch
		cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/02_T1/
		cp SkullStripped_biascorrected.nii /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/ANTS_Template_Processing_Folder_Crunch_Batch
		
		cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/ANTS_Template_Processing_Folder_Crunch_Batch
		mv -v SkullStripped_biascorrected.nii "${SUB}_SkullStripped_biascorrected.nii"
	done
	cd /ufrc/rachaelseidler/tfettrow/Crunch_Code/Shell_Scripts
	cp run_ANTS.batch /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/ANTS_Template_Processing_Folder_Crunch_Batch
	cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/ANTS_Template_Processing_Folder_Crunch_Batch
	sbatch run_ANTS.batch
	#rm run_ANTS_MVT.batch
fi
