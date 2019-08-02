subjects=(CrunchPilot02)

#####################################################################################
ml fsl

for SUB in ${subjects[@]}; do

	Fieldmap_dir=/ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/03_Fieldmaps
	cd ${Fieldmap_dir}/Fieldmap_imagery

	# Equation for how to find total read out time? ===== #Total readout time (FSL) = (MatrixSizePhase - 1) * EffectiveEchoSpacing ====  (96 - 1) * .213333 ==== .0203 seconds
	echo 0 -1 0 .0203 >> acqParams_imagery.txt
	echo 0  1 0 .0203 >> acqParams_imagery.txt
	gunzip *nii.gz*
	fslmerge -t AP_PA_merged_imagery fMRIDistMapAP.nii fMRIDistMapPA.nii
	topup --imain=AP_PA_merged_imagery.nii --datain=acqParams_imagery.txt --fout=my_fieldmap_imagery --config=b02b0.cnf --iout=se_epi_unwarped_imagery --out=topup_results_imagery
	ml fsl/5.0.8
	fslchfiletype ANALYZE my_fieldmap_imagery.nii fpm_my_fieldmap_imagery
	#fslmaths se_epi_unwarped_imagery -Tmean my_fieldmap_mask_imagery
	gunzip *nii.gz*

	cd ${Fieldmap_dir}/Fieldmap_nback
	gunzip *nii.gz*
	echo 0 -1 0 .0203 >> acqParams_nback.txt 
	echo 0  1 0 .0203 >> acqParams_nback.txt
	ml fsl
	fslmerge -t AP_PA_merged_nback fMRIDistMapAP.nii fMRIDistMapPA.nii
	topup --imain=AP_PA_merged_nback.nii --datain=acqParams_nback.txt --fout=my_fieldmap_nback --config=b02b0.cnf --iout=se_epi_unwarped_nback --out=topup_results_nback
	ml fsl/5.0.8
	# convert to hdr
	fslchfiletype ANALYZE my_fieldmap_nback.nii fpm_my_fieldmap_nback
	#fslmaths se_epi_unwarped_nback -Tmean my_fieldmap_mask_nback
	gunzip *nii.gz*
done