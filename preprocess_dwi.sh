subjects=(CrunchPilot02)

#preprocessing_steps=("rician_filter")
#preprocessing_steps=("fieldmap_dti")
#preprocessing_steps=("eddy_correction")
preprocessing_steps=("skull_strip")

for SUB in ${subjects[@]}; do
   	#if [[ ${preprocessing_steps[*]} =~ "rician_filter" ]]; then
   		# MainDWIDenoising # # 
   		# # arguments  to automate ?? X X
   	#fi
   	if [[ ${preprocessing_steps[*]} =~ "fieldmap_dti" ]]; then
   		Fieldmap_dir=/ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/03_Fieldmaps
		cd ${Fieldmap_dir}/Fieldmap_dti
		# Equation for how to find total read out time? ===== #Total readout time (FSL) = (MatrixSizePhase - 1) * EffectiveEchoSpacing ====  (128 - 1) * 0.27999 ==== .0355 seconds
		echo 0 -1 0 .0355 >> acqParams.txt
		echo 0 -1 0 .0355 >> acqParams.txt
		echo 0 -1 0 .0355 >> acqParams.txt
		echo 0 -1 0 .0355 >> acqParams.txt
		echo 0 -1 0 .0355 >> acqParams.txt
		echo 0  1 0 .0355 >> acqParams.txt
		echo 0  1 0 .0355 >> acqParams.txt
		echo 0  1 0 .0355 >> acqParams.txt
		echo 0  1 0 .0355 >> acqParams.txt
		echo 0  1 0 .0355 >> acqParams.txt


		#NVOL=`fslnvols ep2ddiff5B0DT_denoised_68slices`
		#for ((i=1; i<=${NVOL}; i+=1)); do indx="$indx 1"; done; echo $indx > index.txt

		
		ml fsl
		fslmerge -t AP_PA_merged ep2ddiff5B0DistMapAP.nii ep2ddiff5B0DistMapPA.nii
		
		# need to remove a slice for even #
		fslsplit AP_PA_merged.nii slice -z
		gunzip *nii.gz*
		rm slice0000.nii
		fslmerge -z AP_PA_merged_68slices slice0*
		rm slice00*.nii
		#
		topup --imain=AP_PA_merged_68slices.nii --datain=acqParams.txt --fout=my_fieldmap_dti --config=b02b0.cnf --iout=se_epi_unwarped_dti --out=topup_results_dti

		fslmaths my_fieldmap_dti -mul 6.28 my_fieldmap_rads_dti
		fslmaths se_epi_unwarped_dti -Tmean my_fieldmap_mask_dti
		bet2 my_fieldmap_mask_dti my_fieldmap_mask_brain_dti
		gunzip *nii.gz*
   	fi
   	if [[ ${preprocessing_steps[*]} =~ "eddy_correction" ]]; then
   		cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/03_Fieldmaps/Fieldmap_dti
       
   		cp my_fieldmap_mask_brain_dti.nii /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/08_DWI
		cp my_fieldmap_dti.nii /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/08_DWI
		cp acqParams.txt /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/08_DWI
        cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/08_DWI
		
		ml fsl

   		# need to remove  a slice from DWI data
   		fslsplit ep2ddiff5B0DT_denoised slice -z
		# Remove slice 0000 (remove the most inferior slice). Check what this slice looks like before you delete it!
		rm slice0000.nii.gz
		# Merge remaining slices
		fslmerge -z ep2ddiff5B0DT_denoised_68slices slice0*
		## We're done with the remaining inidividual slices so delete them
		rm slice00*.nii.gz
		gunzip *nii.gz*

		NVOL=`fslnvols ep2ddiff5B0DT_denoised_68slices`
		for ((i=1; i<=${NVOL}; i+=1)); do indx="$indx 1"; done; echo $indx > index.txt

		fslmaths ep2ddiff5B0DT_denoised_68slices -Tmean Mean_ep2ddiff5B0DT_denoised_68slices

		flirt -in my_fieldmap_mask_brain_dti.nii -ref Mean_ep2ddiff5B0DT_denoised_68slices.nii -out my_fieldmap_mask_brain_dti_pixAdjust.nii
	
		eddy_openmp --imain=ep2ddiff5B0DT_denoised_68slices --mask=my_fieldmap_mask_brain_dti_pixAdjust --acqp=acqParams.txt --index=index.txt --bvecs=ep2ddiff5B0DT.bvec --bvals=ep2ddiff5B0DT.bval --out=eddy_corrected_data

	fi
	if [[ ${preprocessing_steps[*]} =~ "skull_strip" ]]; then
		cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/08_DWI
		ml fsl
		bet2 eddy_corrected_data.nii eddy_corrected_Skullstripped.nii
	fi
done
