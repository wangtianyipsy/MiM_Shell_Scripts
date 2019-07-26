subjects=(CrunchPilot02)

#####################################################################################
ml fsl

for SUB in ${subjects[@]}; do

	Subject_dir=/ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/

	# Create folders
	mkdir -p ${Subject_dir}/Processed/MRI_files/01_Localizer
	mkdir -p ${Subject_dir}/Processed/MRI_files/02_T1
	mkdir -p ${Subject_dir}/Processed/MRI_files/03_Fieldmaps
	mkdir -p ${Subject_dir}/Processed/MRI_files/03_Fieldmaps/Fieldmap_imagery
	mkdir -p ${Subject_dir}/Processed/MRI_files/03_Fieldmaps/Fieldmap_nback
	mkdir -p ${Subject_dir}/Processed/MRI_files/03_Fieldmaps/Fieldmap_dti
	mkdir -p ${Subject_dir}/Processed/MRI_files/04_rsfMRI
	mkdir -p ${Subject_dir}/Processed/MRI_files/05_MotorImagery
	mkdir -p ${Subject_dir}/Processed/MRI_files/06_Nback
	mkdir -p ${Subject_dir}/Processed/MRI_files/07_ASL
	mkdir -p ${Subject_dir}/Processed/MRI_files/08_DWI
	mkdir -p ${Subject_dir}/Processed/MRI_files/09_Perfusion

	mkdir -p ${Subject_dir}/Figures
	mkdir -p ${Subject_dir}/Processed/Nback_files

	####################################################################################
	# Localizer
	cd ${Subject_dir}/Raw/MRI_files/LOCALIZER_0001
	rm *nii.gz*
	dcm2nii -a n -i y -r n -x n ${Subject_dir}/Raw/MRI_files/LOCALIZER_0001
	cp *nii.gz*          ${Subject_dir}/Processed/MRI_files/01_Localizer;
	cd ${Subject_dir}/Processed/MRI_files/01_Localizer
	rm *.nii
	gunzip *nii.gz*

	i=1
	for file in *.nii; do
		mv -v ${file} "${file:15:9}$((i++)).nii"
	done

	#####################################################################################
	# T1 Image
	cd ${Subject_dir}/Raw/MRI_files/T1_MPRAGE_SAG_ISO_8MM_0006
	rm *nii.gz*
	dcm2nii -a n -i y -r n -x n ${Subject_dir}/Raw/MRI_files/T1_MPRAGE_SAG_ISO_8MM_0006
	cp *nii.gz*          ${Subject_dir}/Processed/MRI_files/02_T1;
	cd ${Subject_dir}/Processed/MRI_files/02_T1
	rm *.nii
	gunzip *nii.gz*
	
	for file in *.nii; do
		mv -v ${file} "${file:15:2}.nii"
	done

	####################################################################################
	# Field Maps
	cd ${Subject_dir}/Raw/MRI_files/FMRI-DISTMAP_AP_0015
	rm *nii.gz*
	dcm2nii -a n -i y -r n -x n ${Subject_dir}/Raw/MRI_files/FMRI-DISTMAP_AP_0015
	cp *nii.gz*          ${Subject_dir}/Processed/MRI_files/03_Fieldmaps/Fieldmap_imagery;
	
	cd ${Subject_dir}/Raw/MRI_files/FMRI-DISTMAP_PA_0011
	rm *nii.gz*
	dcm2nii -a n -i y -r n -x n ${Subject_dir}/Raw/MRI_files/FMRI-DISTMAP_PA_0011
	cp *nii.gz*          ${Subject_dir}/Processed/MRI_files/03_Fieldmaps/Fieldmap_imagery;
	cd ${Subject_dir}/Processed/MRI_files/03_Fieldmaps/Fieldmap_imagery
	rm *.nii
	gunzip *nii.gz*

	for file in *.nii; do
		mv -v ${file} "${file:15:13}.nii"
	done

	cd ${Subject_dir}/Raw/MRI_files/FMRI-DISTMAP_AP_0025
	rm *nii.gz*
	dcm2nii -a n -i y -r n -x n ${Subject_dir}/Raw/MRI_files/FMRI-DISTMAP_AP_0025
	cp *nii.gz*          ${Subject_dir}/Processed/MRI_files/03_Fieldmaps/Fieldmap_nback;
	
	cd ${Subject_dir}/Raw/MRI_files/FMRI-DISTMAP_PA_0021
	rm *nii.gz*
	dcm2nii -a n -i y -r n -x n ${Subject_dir}/Raw/MRI_files/FMRI-DISTMAP_PA_0021
	cp *nii.gz*          ${Subject_dir}/Processed/MRI_files/03_Fieldmaps/Fieldmap_nback;
	cd ${Subject_dir}/Processed/MRI_files/03_Fieldmaps/Fieldmap_nback
	rm *.nii
	gunzip *nii.gz*

	for file in *.nii; do
		mv -v ${file} "${file:15:13}.nii"
	done

	cd ${Subject_dir}/Raw/MRI_files/EP2D_DIFF_5B0_DISTMAP_AP_0043
	rm *nii.gz*
	dcm2nii -a n -i y -r n -x n ${Subject_dir}/Raw/MRI_files/EP2D_DIFF_5B0_DISTMAP_AP_0043
	cp *nii.gz*          ${Subject_dir}/Processed/MRI_files/03_Fieldmaps/Fieldmap_dti;
	
	cd ${Subject_dir}/Raw/MRI_files/EP2D_DIFF_5B0_DISTMAP_PA_0044
	rm *nii.gz*
	dcm2nii -a n -i y -r n -x n ${Subject_dir}/Raw/MRI_files/EP2D_DIFF_5B0_DISTMAP_PA_0044
	cp *nii.gz*          ${Subject_dir}/Processed/MRI_files/03_Fieldmaps/Fieldmap_dti;
	cd ${Subject_dir}/Processed/MRI_files/03_Fieldmaps/Fieldmap_dti
	rm *.nii
	gunzip *nii.gz*

	for file in *.nii; do
		mv -v ${file} "${file:15:20}.nii"
	done
	####################################################################################
	# Resting State
	cd ${Subject_dir}/Raw/MRI_files/RESTSTATE-FMRI_8MIN_0009
	rm *nii.gz*
	dcm2nii -a n -i y -r n -x n ${Subject_dir}/Raw/MRI_files/RESTSTATE-FMRI_8MIN_0009
	cp *nii.gz*          ${Subject_dir}/Processed/MRI_files/04_rsfMRI;
	cd ${Subject_dir}/Processed/MRI_files/04_rsfMRI
	rm *.nii
	gunzip *nii.gz*

	for file in *.nii; do
		mv -v ${file} "${file:15:13}.nii"
	done

	#####################################################################################
	# Motor Imagery fMRI Runs
	cd ${Subject_dir}/Raw/MRI_files/FMRI01_RUN1_0017
	rm *nii.gz*
	dcm2nii -a n -i y -r n -x n ${Subject_dir}/Raw/MRI_files/FMRI01_RUN1_0017
	cp *nii.gz*          ${Subject_dir}/Processed/MRI_files/05_MotorImagery;

	cd ${Subject_dir}/Raw/MRI_files/FMRI01_RUN2_0019
	rm *nii.gz*
	dcm2nii -a n -i y -r n -x n ${Subject_dir}/Raw/MRI_files/FMRI01_RUN2_0019
	cp *nii.gz*          ${Subject_dir}/Processed/MRI_files/05_MotorImagery;
	cd ${Subject_dir}/Processed/MRI_files/05_MotorImagery
	rm *.nii
	gunzip *nii.gz*

	for file in *.nii; do
		mv -v ${file} "${file:15:10}.nii"
	done

	####################################################################################
	## Nback fMRI Runs
	cd ${Subject_dir}/Raw/MRI_files/FMRI02_RUN1_0027
	rm *nii.gz*
	dcm2nii -a n -i y -r n -x n ${Subject_dir}/Raw/MRI_files/FMRI02_RUN1_0027
	cp *nii.gz*          ${Subject_dir}/Processed/MRI_files/06_Nback;

	cd ${Subject_dir}/Raw/MRI_files/FMRI02_RUN2_0029
	rm *nii.gz*
	dcm2nii -a n -i y -r n -x n ${Subject_dir}/Raw/MRI_files/FMRI02_RUN2_0029
	cp *nii.gz*          ${Subject_dir}/Processed/MRI_files/06_Nback;

	cd ${Subject_dir}/Raw/MRI_files/FMRI02_RUN3_0031
	rm *nii.gz*
	dcm2nii -a n -i y -r n -x n ${Subject_dir}/Raw/MRI_files/FMRI02_RUN3_0031
	cp *nii.gz*          ${Subject_dir}/Processed/MRI_files/06_Nback;


	cd ${Subject_dir}/Raw/MRI_files/FMRI02_RUN4_0033
	rm *nii.gz*
	dcm2nii -a n -i y -r n -x n ${Subject_dir}/Raw/MRI_files/FMRI02_RUN4_0033
	cp *nii.gz*          ${Subject_dir}/Processed/MRI_files/06_Nback;
	cd ${Subject_dir}/Processed/MRI_files/06_Nback
	rm *.nii
	gunzip *nii.gz*

	for file in *.nii; do
		mv -v ${file} "${file:15:10}.nii"
	done

	####################################################################################
	# Arterial Spin Labeling 
	cd ${Subject_dir}/Raw/MRI_files/ASL_2D_TRA_FULLBRAIN_0035
	rm *nii.gz*
	dcm2nii -a n -i y -r n -x n ${Subject_dir}/Raw/MRI_files/ASL_2D_TRA_FULLBRAIN_0035
	cp *nii.gz*          ${Subject_dir}/Processed/MRI_files/07_ASL;

	cd ${Subject_dir}/Raw/MRI_files/ASL_2D_TRA_FULLBRAIN_0039
	rm *nii.gz*
	dcm2nii -a n -i y -r n -x n ${Subject_dir}/Raw/MRI_files/ASL_2D_TRA_FULLBRAIN_0039
	cp *nii.gz*          ${Subject_dir}/Processed/MRI_files/07_ASL;
	cd ${Subject_dir}/Processed/MRI_files/07_ASL
	rm *.nii
	gunzip *nii.gz*

	i=1
	for file in *.nii; do
		mv -v ${file} "${file:15:17}$((i++)).nii"
	done

	#####################################################################################
	## Diffusion Weighted Imaging
	cd ${Subject_dir}/Raw/MRI_files/EP2D_DIFF_5B0_DTI_64DIR_0046
	rm *nii.gz*
	dcm2nii -a n -i y -r n -x n ${Subject_dir}/Raw/MRI_files/EP2D_DIFF_5B0_DTI_64DIR_0046
	cp *nii.gz*          ${Subject_dir}/Processed/MRI_files/08_DWI;
	cd ${Subject_dir}/Processed/MRI_files/08_DWI
	rm *.nii
	gunzip *nii.gz*

	for file in *.nii; do
		mv -v ${file} "${file:15:13}.nii"
	done
	#####################################################################################
	# Perfusion
	cd ${Subject_dir}/Raw/MRI_files/PERFUSION_WEIGHTED_0037
	rm *nii.gz*
	dcm2nii -a n -i y -r n -x n ${Subject_dir}/Raw/MRI_files/PERFUSION_WEIGHTED_0037
	cp *nii.gz*          ${Subject_dir}/Processed/MRI_files/09_Perfusion;

	cd ${Subject_dir}/Raw/MRI_files/PERFUSION_WEIGHTED_0041
	rm *nii.gz*
	dcm2nii -a n -i y -r n -x n ${Subject_dir}/Raw/MRI_files/PERFUSION_WEIGHTED_0041
	cp *nii.gz*          ${Subject_dir}/Processed/MRI_files/09_Perfusion;
	cd ${Subject_dir}/Processed/MRI_files/09_Perfusion
	rm *.nii
	gunzip *nii.gz*
	i=1
	for file in *.nii; do
		mv -v ${file} "${file:15:17}$((i++)).nii"
	done
done
