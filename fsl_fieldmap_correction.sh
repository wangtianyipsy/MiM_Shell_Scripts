subjects=(CrunchPilot03)

#####################################################################################
ml fsl

for SUB in ${subjects[@]}; do

	Fieldmap_dir=/ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/03_Fieldmaps

	cd ${Fieldmap_dir}/Fieldmap_imagery

	echo 0 -1 0 .0203 >> acqParams_imagery.txt
	echo 0  1 0 .0203 >> acqParams_imagery.txt

	gunzip *nii.gz*
	fslmerge -t AP_PA_merged_imagery fMRIDistMapAP.nii fMRIDistMapPA.nii

	topup --imain=AP_PA_merged_imagery.nii --datain=acqParams_imagery.txt --fout=my_fieldmap_imagery --config=b02b0.cnf --iout=se_epi_unwarped_imagery --out=topup_results_imagery

	ml fsl/5.0.8

	fslchfiletype ANALYZE my_fieldmap_imagery.nii fpm_my_fieldmap_imagery

	fslmaths se_epi_unwarped_imagery -Tmean my_fieldmap_mag_imagery
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

	fslmaths se_epi_unwarped_nback -Tmean my_fieldmap_mag_nback
	gunzip *nii.gz*


	# Not the same datain file as fMRI 

	#cd ${Fieldmap_dir}/Fieldmap_dti
	#gunzip *nii.gz*
	#fslmerge -t AP_PA_merged_dti DTIDistMapAP.nii DTIDistMapPA.nii
	#topup --imain=AP_PA_merged_dti.nii.gz --datain=datain.txt --fout=my_fieldmap_dti --iout=se_epi_unwarped_dti --out=topup_results_dti
	#fslmaths my_fieldmap_dti -mul 6.28 my_fieldmap_rads_dti
	#fslmaths se_epi_unwarped_dti -Tmean my_fieldmap_mag_dti
	#bet2 my_fieldmap_mag_dti my_fieldmap_mag_brain_dti
	#
	# check the index size 
	#indx=""
	#for ((i=1; i<=64; i+=1)); do indx="$indx 1"; done
	#echo $indx > index.txt

done