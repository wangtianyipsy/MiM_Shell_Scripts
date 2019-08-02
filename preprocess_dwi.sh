subjects=(CrunchPilot02)

#preprocessing_steps=("rician_filter")
preprocessing_steps=("fieldmap_dti")
#preprocessing_steps=("eddy_correction")

for SUB in ${subjects[@]}; do
   	#if [[ ${preprocessing_steps[*]} =~ "rician_filter" ]]; then

   	#fi
   	if [[ ${preprocessing_steps[*]} =~ "fieldmap_dti" ]]; then
   		Fieldmap_dir=/ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/03_Fieldmaps
		cd ${Fieldmap_dir}/Fieldmap_dti
		# Equation for how to find total read out time? ===== #Total readout time (FSL) = (MatrixSizePhase - 1) * EffectiveEchoSpacing ====  (128 - 1) * 0.27999 ==== .0355 seconds
		echo 0 -1 0 .0355 >> acqParams.txt
		echo 0 -1 0 .0355 >> acqParams.txt
		echo 0 -1 0 .0355 >> acqParams.txt
		echo 0 -1 0 .0355 >> acqParams.txt
		echo 0  1 0 .0355 >> acqParams.txt
		echo 0  1 0 .0355 >> acqParams.txt
		echo 0  1 0 .0355 >> acqParams.txt
		echo 0  1 0 .0355 >> acqParams.txt
		echo 0  1 0 .0355 >> acqParams.txt

		# need to remove a slice

		ml fsl
		fslmerge -t AP_PA_merged ep2ddiff5B0DistMapAP.nii ep2ddiff5B0DistMapPA.nii
		topup --imain=AP_PA_merged.nii --datain=acqParams.txt --fout=my_fieldmap_dti --config=b02b0.cnf --iout=se_epi_unwarped_dti --out=topup_results_dti
		#fslmaths my_fieldmap_dti -mul 6.28 my_fieldmap_rads_dti
		fslmaths se_epi_unwarped_dti -Tmean my_fieldmap_mask_dti
		bet2 my_fieldmap_mask_dti my_fieldmap_mask_brain_dti
		gunzip *nii.gz*
   	fi
   	if [[ ${preprocessing_steps[*]} =~ "eddy_correction" ]]; then
   		Fieldmap_dir=/ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/03_Fieldmaps
		cd ${Fieldmap_dir}/Fieldmap_dti
		eddy --imain=data --mask=my_fieldmap_mask_brain_dti --acqp=acqParams.txt --index=index.txt --bvecs=bvecs --bvals=bvals --topup=my_topup_results --out=eddy_corrected_data
		# what is index
		# need fmri data ^^
	fi
done
