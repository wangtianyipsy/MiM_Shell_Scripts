	
subjects=(CrunchPilot01_development2)
#subjects=(ClarkPilot_01 ClarkPilot_02)


#ants_processing_steps=("n4_bias_correction")

#ants_processing_steps=("ants_create_MVT")
#ants_processing_steps=("ants_registration_MVT_2_MNI")
#ants_processing_steps=("ants_apply_transform_MVT_2_MNI")
#ants_processing_steps=("grab_MVT_material")

# only necessary if NOT doing in spm.. for now use coregistered2vdm
#ants_processing_steps=("ants_registration_Func_2_T1") 
#ants_processing_steps=("ants_apply_transform_Func_2_T1")


#only necessary if not using MVT.. otherwise T1 -> MVT -> MNI
ants_processing_steps=("ants_registration_T1_2_MNI")
#ants_processing_steps=("ants_apply_transform_T1_2_MNI")


#ants_processing_steps=("ants_apply_transform_MVT_2_MNI")

#ants_processing_steps=("ants_apply_transform_Func_2_MNI")


# # # TO DO: 
# create option to run MVT and ANTSreg locally or batch
# what is a dilated segmentation??
# implement 06_Nback
# implement multiple runs
# shorten file paths (create groupAnts_dir and subectAnts_dir)
# Func -> T1 -> MVT -> MNI  
# adjust MVT file output name to Sub_T1_to_MVT
# move them to the "processing folder" and change file name to include subjectI
# move .batch to "processing folder" 


for SUB in ${subjects[@]}; do
	Subject_dir=/ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/
	Ants_dir=/ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/ANTS_Template_Processing_Folder_Crunch/
	if [[ ${ants_processing_steps[*]} =~ "n4_bias_correction" ]]; then
		data_folder_to_analyze=(02_T1 05_MotorImagery)
		for DAT_Folder in ${data_folder_to_analyze[@]}; do
			ml gcc/5.2.0; ml ants 
			mkdir -p ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing
			#if [[ $DAT_Folder == 02_T1 ]]; then
			#	cd ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/
			#	N4BiasFieldCorrection -i SkullStripped_Template.nii -o SkullStripped_biascorrected.nii
			#fi
			if [[ $DAT_Folder == 05_MotorImagery ]]; then
				cd ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/
				ml fsl
				fslmaths unwarpedRealigned_coregistered2vdm_slicetimed_fMRI01_Run1.nii -Tmean Mean_unwarpedRealigned_coregistered2vdm_slicetimed_fMRI01_Run1.nii
				gunzip *.nii.gz*
				N4BiasFieldCorrection -i Mean_unwarpedRealigned_coregistered2vdm_slicetimed_fMRI01_Run1.nii -o Biascorrected_Mean_unwarpedRealigned_coregistered2vdm_slicetimed_fMRI01_Run1.nii
				cp Mean_unwarpedRealigned_coregistered2vdm_slicetimed_fMRI01_Run1.nii ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing
				rm Mean_unwarpedRealigned_coregistered2vdm_slicetimed_fMRI01_Run1.nii
			fi
		done
	fi

	if [[ ${ants_processing_steps[*]} =~ "grab_MVT_material" ]]; then
		data_folder_to_analyze=(05_MotorImagery)
		for DAT_Folder in ${data_folder_to_analyze[@]}; do
			mkdir -p ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing
	
			cp ${Ants_dir}/multivariate_template0.nii ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing
			cp ${Ants_dir}/multivariate_CrunchPilot02_SkullStripped_biascorrected01Warp.nii ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing
			cp ${Ants_dir}/multivariate_CrunchPilot02_SkullStripped_biascorrected01InverseWarp.nii ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing
			cp ${Ants_dir}/multivariate_CrunchPilot02_SkullStripped_biascorrected00GenericAffine.mat ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing
	
			cp ${Ants_dir}/MVT_to_MNI_0GenericAffine.mat ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing
			cp ${Ants_dir}/MVT_to_MNI_1InverseWarp.nii ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing
			cp ${Ants_dir}/MVT_to_MNI_1Warp.nii ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing
			cp ${Ants_dir}/MVT_to_MNI_Warped.nii ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing
	
			cp ${Subject_dir}/Processed/MRI_files/02_T1/SkullStripped_biascorrected.nii ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing
	
			cp /ufrc/rachaelseidler/tfettrow/Crunch_Code/MR_Templates/_ANTs_c0cTemplate_T1_IXI555_MNI152_GS_brain.nii ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing
		done
	fi

	if [[ ${ants_processing_steps[*]} =~ "ants_registration_Func_2_T1" ]]; then
		data_folder_to_analyze=(05_MotorImagery)
		for DAT_Folder in ${data_folder_to_analyze[@]}; do

			# Create folders
			mkdir -p ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing

			ml gcc/5.2.0
			ml ants

			cp ${Subject_dir}/Processed/MRI_files/02_T1/SkullStripped_biascorrected.nii ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing
			cp ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/Biascorrected_Mean_unwarpedRealigned_coregistered2vdm_slicetimed_fMRI01_Run1.nii ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing

			outputFolder=${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing
			Mean_Func=${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing/Biascorrected_Mean_unwarpedRealigned_coregistered2vdm_slicetimed_fMRI01_Run1.nii
			T1_Template=${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing/SkullStripped_biascorrected.nii
			
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
			        #--transform Affine[0.1] \
			        #--metric MI[$Mean_Func,$T1_Template,1,32,Regular,0.25] \
			        #--convergence [1000x500x250x100,1e-6,10] \
			        #--shrink-factors 8x4x2x1 \
			        #--smoothing-sigmas 3x2x1x0vox
			        #--transform SyN[0.1,3,0] \
			        #--metric CC[$Mean_Func,$T1_Template,1,4] \
			        #--convergence [100x70x50x20,1e-6,10] \
			        #--shrink-factors 8x4x2x1 \
			        #--smoothing-sigmas 3x2x1x0vox

			#antsRegistration --dimensionality 3 --float 0 \
			#        --output [$outputFolder/T1_to_Func_,$outputFolder/T1_to_Func_Warped.nii.gz] \
			#        --interpolation Linear \
			#        --winsorize-image-intensities [0.005,0.995] \
			#        --use-histogram-matching 0 \
			#        --initial-moving-transform [$T1_Template,$Mean_Func,1] \
			#        --transform Rigid[0.1] \
			#        --metric MI[$T1_Template,$Mean_Func,1,32,Regular,0.25] \
			#        --convergence [1000x500x250x100,1e-6,10] \
			#        --shrink-factors 8x4x2x1 \
			#        --smoothing-sigmas 3x2x1x0vox \
			#        --transform Affine[0.1] \
			#        --metric MI[$T1_Template,$Mean_Func,1,32,Regular,0.25] \
			#        --convergence [1000x500x250x100,1e-6,10] \
			#        --shrink-factors 8x4x2x1 \
			#        --smoothing-sigmas 3x2x1x0vox \
			#        --transform SyN[0.1,3,0] \
			#        --metric CC[$T1_Template,$Mean_Func,1,4] \
			#        --convergence [100x70x50x20,1e-6,10] \
			#        --shrink-factors 8x4x2x1 \
			#        --smoothing-sigmas 3x2x1x0vox

		done
	fi
	if [[ ${ants_processing_steps[*]} =~ "ants_registration_T1_2_MNI" ]]; then
		data_folder_to_analyze=(05_MotorImagery)
		for DAT_Folder in ${data_folder_to_analyze[@]}; do
			# Create folders
			mkdir -p ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing

			ml gcc/5.2.0
			ml ants

			outputFolder=${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing
			T1_Template=${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing/SkullStripped_biascorrected.nii
			MNI_Template=/ufrc/rachaelseidler/tfettrow/Crunch_Code/MR_Templates/_ANTs_c0cTemplate_T1_IXI555_MNI152_GS_brain.nii
			
			antsRegistration --dimensionality 3 --float 0 \
        	--output [$outputFolder/T1_to_MNIc0c_,$outputFolder/T1_to_MNIc0c_Warped.nii.gz] \
        	--interpolation Linear \
        	--winsorize-image-intensities [0.005,0.995] \
        	--use-histogram-matching 1 \
        	--initial-moving-transform [$MNI_Template,$T1_Template,1] \
        	--transform Rigid[0.1] \
        	--metric MI[$MNI_Template,$T1_Template,1,64,Regular,0.5] \
        	--convergence [1000x500x250x100,1e-6,10] \
        	--shrink-factors 8x4x2x1 \
        	--smoothing-sigmas 3x2x1x0vox \
        	--transform Affine[0.1] \
        	--metric MI[$MNI_Template,$T1_Template,1,64,Regular,0.5] \
        	--convergence [1000x500x250x100,1e-6,10] \
        	--shrink-factors 8x4x2x1 \
        	--smoothing-sigmas 3x2x1x0vox \
        	--transform SyN[0.1,3,0] \
        	--metric CC[$MNI_Template,$T1_Template,1,10] \
        	--convergence [100x70x50x20,1e-6,10] \
        	--shrink-factors 8x4x2x1 \
        	--smoothing-sigmas 3x2x1x0vox

        	gunzip *.nii.gz*
        done
	fi
	if [[ ${ants_processing_steps[*]} =~ "ants_apply_transform_T1_2_MNI" ]]; then
		data_folder_to_analyze=(05_MotorImagery)
		for DAT_Folder in ${data_folder_to_analyze[@]}; do
			cd ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing
			ml gcc/5.2.0
			ml ants
			
			antsApplyTransforms -d 3 -e 3 -i SkullStripped_biascorrected.nii -r ANTs_c0Template_T1_IXI555_MNI152_GS_brain.nii \
			-n BSpline -o SkullStripped_biascorrected_warpedToMNI.nii -t [T1_to_MNI_0GenericAffine.mat,1] -t [T1_to_MNI_1InverseWarp.nii] -v 

		done
    fi

	if [[ ${ants_processing_steps[*]} =~ "ants_apply_transform_Func_2_T1" ]]; then
		data_folder_to_analyze=(05_MotorImagery)
		for DAT_Folder in ${data_folder_to_analyze[@]}; do


			cd ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing
			ml gcc/5.2.0
			ml ants
			antsApplyTransforms -d 3 -e 3 -i Biascorrected_Mean_unwarpedRealigned_coregistered2vdm_slicetimed_fMRI01_Run1.nii -r SkullStripped_biascorrected.nii \
			-n BSpline -o Biascorrected_Mean_unwarpedRealigned_coregistered2vdm_slicetimed_fMRI01_Run1_warpedToT1.nii -t [Func_to_T1_0GenericAffine.mat,0] -v 

			#antsApplyTransforms -d 3 -e 3 -i mean_unwarpedRealigned_slicetimed_fMRI01Run1_biascorrected.nii -r SkullStripped_biascorrected.nii \
			#-n BSpline -o mean_unwarpedRealigned_slicetimed_biascorrected_InverseWarpedToT1.nii -t [Func_to_T1_0GenericAffine.mat,1] -t [Func_to_T1_1InverseWarp.nii] -v 
		done
	fi
	if [[ ${ants_processing_steps[*]} =~ "ants_apply_transform_MVT_2_MNI" ]]; then
		data_folder_to_analyze=(05_MotorImagery)
		for DAT_Folder in ${data_folder_to_analyze[@]}; do
			

			cd ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing

			antsApplyTransforms -d 3 -e 3 -i multivariate_template0.nii -r ANTs_c0Template_T1_IXI555_MNI152_GS_brain.nii \
			-n BSpline -o MVT_warpedTo_MNI.nii -t [MVT_to_MNI_0GenericAffine.mat,1] -t [MVT_to_MNI_1InverseWarp.nii] -v 
		done
	fi
	#if [[ ${ants_processing_steps[*]} =~ "ants_apply_transform_Func_2_MNI_withMVT" ]]; then
	#	data_folder_to_analyze=(05_MotorImagery)
	#	for DAT_Folder in ${data_folder_to_analyze[@]}; do
#
	#		cp /ufrc/rachaelseidler/tfettrow/Crunch_Code/MR_Templates/_ANTs_c0cTemplate_T1_IXI555_MNI152_GS_brain.nii ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing
	#		#cp ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/unwarpedRealigned_slicetimed_fMRI01Run1.nii ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing
	#		#cp ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/meanunwarpedRealigned_slicetimed_fMRI01Run1.nii ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing
	#		cp ${Ants_dir}/MVT_to_MNI_0GenericAffine.mat ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing
	#		cp ${Ants_dir}/MVT_to_MNI_1InverseWarp.nii ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing
	#		cp ${Ants_dir}/MVT_to_MNI_1Warp.nii ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing
	#		cp ${Ants_dir}/MVT_to_MNI_Warped.nii ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing
#
	#		cp ${Ants_dir}/multivariate_CrunchPilot02_SkullStripped_biascorrected01Warp.nii ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing
	#		cp ${Ants_dir}/multivariate_CrunchPilot02_SkullStripped_biascorrected01InverseWarp.nii ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing
	#		cp ${Ants_dir}/multivariate_CrunchPilot02_SkullStripped_biascorrected00GenericAffine.mat ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing
	#		
	#		cd ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing
#
	#		gunzip *.nii.gz*
#
	#		ml gcc/5.2.0; ml ants
	#		ml fsl
	#			
	#		antsApplyTransforms -d 3 -e 3 -i unwarpedRealigned_slicetimed_fMRI01Run1.nii -r ANTs_c0Template_T1_IXI555_MNI152_GS_brain.nii \
	#		-n BSpline -o Func_warpedTo_MNI_withMVT.nii -t [MVT_to_MNI_0GenericAffine.mat,1] -t [MVT_to_MNI_1InverseWarp.nii] \
	#		-t [multivariate_CrunchPilot02_SkullStripped_biascorrected00GenericAffine.mat,1] -t [multivariate_CrunchPilot02_SkullStripped_biascorrected01InverseWarp.nii]\
	#		-t [Func_to_T1_0GenericAffine.mat,1] -t [Func_to_T1_1InverseWarp.nii] -v
#
	#		## Func -> T1 -> MVT -> MNI
	#		# Func -> T1 ... warp
	#		# T1 -> MVT ... warp
	#		# MVT -> MNI ... warp
	#	done
	#fi
	if [[ ${ants_processing_steps[*]} =~ "ants_apply_transform_Func_2_MNI" ]]; then
		data_folder_to_analyze=(05_MotorImagery)
		for DAT_Folder in ${data_folder_to_analyze[@]}; do
			
			cd ${Subject_dir}/Processed/MRI_files/${DAT_Folder}/ANTS_Processing

			ml gcc/5.2.0; ml ants
			#ml fsl
			#fslmaths coregistered2t1_unwarpedRealigned_coregistered2vdm_slicetimed_fMRI01_Run1.nii -Tmean Mean_coregistered2t1_unwarpedRealigned_coregistered2vdm_slicetimed_fMRI01_Run1.nii	 
			#gunzip *.nii.gz*

			ml fsl
			this_file_header_info=$(fslhd coregistered2t1_unwarpedRealigned_coregistered2vdm_slicetimed_fMRI01_Run1.nii)
			this_file_number_of_volumes=$(echo $this_file_header_info | grep -o dim4.* | tr -s ' ' | cut -d ' ' -f 2)

			fslsplit coregistered2t1_unwarpedRealigned_coregistered2vdm_slicetimed_fMRI01_Run1.nii
			gunzip *.nii.gz*


			for (( this_volume=0; this_volume<=$this_file_number_of_volumes-1; this_volume++ )); do

				#echo $this_volume
				if [ $this_volume -lt 10 ]; then
					this_file_name=vol000$this_volume.nii
				fi
				if [ $this_volume -gt 9 ] && [ $this_volume -lt 100 ]; then
					this_file_name=vol00$this_volume.nii
				fi
				if [ $this_volume -gt 99 ]; then
					this_file_name=vol0$this_volume.nii
				fi
				#echo $this_file_name
		#		echo vol000$this_volume.nii
				antsApplyTransforms -d 3 -e 3 -i $this_file_name -r _ANTs_c0cTemplate_T1_IXI555_MNI152_GS_brain.nii \
				-o warpedTo_MNI_$this_file_name.nii -t [T1_to_MNIc0c_0GenericAffine.mat,1] -v
			done
			rm vol0*
			fslmerge -a T12MNIc0c_LAS_iA.nii warpedTo_MNI_* 		 # type of transformation _ registration type (L= linear, A = Affine, S = syn) _ flow field applied (i = inverse, A = affine.mat, W = warp) 
			rm warpedTo_MNI_* 		
			gunzip *.nii.gz*


			## Func -> T1 -> MVT -> MNI
			# Func -> T1 ... warp
			# T1 -> MVT ... warp
			# MVT -> MNI ... warp
		done
	fi
done

if [[ ${ants_processing_steps[*]} =~ "ants_create_MVT" ]]; then
	for SUB in ${subjects[@]}; do
		# need to grab the biascorrected.nii from the subjects of interest

		mkdir -p ${Ants_dir}
		cd ${Ants_dir}
		cp /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/02_T1/SkullStripped_biascorrected.nii ${Ants_dir}
		mv -v SkullStripped_biascorrected.nii "${SUB}_SkullStripped_biascorrected.nii"
	done
	cp /ufrc/rachaelseidler/tfettrow/Crunch_Code/Shell_Scripts/run_ANTS_MVT.batch ${Ants_dir}
	sbatch run_MVT.batch
	gunzip *.nii.gz*
fi
