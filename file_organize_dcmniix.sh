subjects=(CrunchPilot03)

#####################################################################################
ml mricrogl

for SUB in ${subjects[@]}; do

	Subject_dir=/ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}

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

	###################################################################################
	## Localizer
	cd ${Subject_dir}/Raw/MRI_files/LOCALIZER_0001
	rm *.nii.gz*
	rm *.nii
	rm *.json
#	cm2niix -ba n ${Subject_dir}/Raw/MRI_files/LOCALIZER_0001

	i=1
	for this_nii_file in *.nii*; do
		mv -v ${this_nii_file} "${this_nii_file:15:9}$((i)).nii"
		cp ${this_nii_file:15:9}$((i)).nii ${Subject_dir}/Processed/MRI_files/01_Localizer
		((i++))
	done
	i=1
	for this_json_file in *.json*; do
		mv -v ${this_json_file} "${this_json_file:15:9}$((i)).json"
		cp ${this_json_file:15:9}$((i)).json ${Subject_dir}/Processed/MRI_files/01_Localizer/${this_json_files}
		((i++))
	done
	
	#####################################################################################
	# T1 Image
	cd ${Subject_dir}/Raw/MRI_files/T1_MPRAGE_SAG_ISO_8MM_0006
	rm *.nii.gz*
	rm *.nii
	rm *.json

	dcm2niix -ba n ${Subject_dir}/Raw/MRI_files/T1_MPRAGE_SAG_ISO_8MM_0006

	for nii_file in *.nii*; do
		mv -v ${nii_file} "${nii_file:0:2}.nii"
		cp ${nii_file:0:2}.nii ${Subject_dir}/Processed/MRI_files/02_T1;
	done

	for json_file in *.json*; do
		mv -v ${json_file} "${json_file:0:2}.json"
		cp ${json_file:0:2}.json ${Subject_dir}/Processed/MRI_files/02_T1;
	done

	######################################################################################
	## Field Maps
	cd ${Subject_dir}/Raw/MRI_files/FMRI-DISTMAP_AP_0015
	rm *.nii.gz*
	rm *.nii
	rm *.json
	#dcm2nii -a n -i y -r n -x n ${Subject_dir}/Raw/MRI_files/FMRI-DISTMAP_AP_0015
	dcm2niix -ba n ${Subject_dir}/Raw/MRI_files/FMRI-DISTMAP_AP_0015
	
	for nii_file in *.nii; do
		mv -v ${nii_file} "${nii_file:26:10}.nii"
		cp ${nii_file:26:10}.nii ${Subject_dir}/Processed/MRI_files/03_Fieldmaps/Fieldmap_imagery;
	done
	for json_file in *.json; do
		mv -v ${json_file} "${json_file:26:10}.json"
		cp ${json_file:26:10}.json ${Subject_dir}/Processed/MRI_files/03_Fieldmaps/Fieldmap_imagery;
	done


	cd ${Subject_dir}/Raw/MRI_files/FMRI-DISTMAP_PA_0011
	rm *.nii.gz*
	rm *.nii
	rm *.json
	#dcm2nii -a n -i y -r n -x n ${Subject_dir}/Raw/MRI_files/FMRI-DISTMAP_PA_0011
	dcm2niix -ba n ${Subject_dir}/Raw/MRI_files/FMRI-DISTMAP_PA_0011

	for nii_file in *.nii; do
		mv -v ${nii_file} "${nii_file:26:10}.nii"
		cp ${nii_file:26:10}.nii ${Subject_dir}/Processed/MRI_files/03_Fieldmaps/Fieldmap_imagery;
	done
	for json_file in *.json; do
		mv -v ${json_file} "${json_file:26:10}.json"
		cp ${json_file:26:10}.json ${Subject_dir}/Processed/MRI_files/03_Fieldmaps/Fieldmap_imagery;
	done


	cd ${Subject_dir}/Raw/MRI_files/FMRI-DISTMAP_AP_0025
	rm *.nii.gz*
	rm *.nii
	rm *.json
	#dcm2nii -a n -i y -r n -x n ${Subject_dir}/Raw/MRI_files/FMRI-DISTMAP_AP_0025
	dcm2niix -ba n ${Subject_dir}/Raw/MRI_files/FMRI-DISTMAP_AP_0025
	
	for nii_file in *.nii; do
		mv -v ${nii_file} "${nii_file:26:10}.nii"
		cp ${nii_file:26:10}.nii ${Subject_dir}/Processed/MRI_files/03_Fieldmaps/Fieldmap_nback;
	done
	for json_file in *.json; do
		mv -v ${json_file} "${json_file:26:10}.json"
		cp ${json_file:26:10}.json ${Subject_dir}/Processed/MRI_files/03_Fieldmaps/Fieldmap_nback;
	done


	cd ${Subject_dir}/Raw/MRI_files/FMRI-DISTMAP_PA_0021
	rm *.nii.gz*
	rm *.nii
	rm *.json
	#dcm2nii -a n -i y -r n -x n ${Subject_dir}/Raw/MRI_files/FMRI-DISTMAP_PA_0021
	dcm2niix -ba n ${Subject_dir}/Raw/MRI_files/FMRI-DISTMAP_PA_0021
	
	for nii_file in *.nii; do
		mv -v ${nii_file} "${nii_file:26:10}.nii"
		cp ${nii_file:26:10}.nii ${Subject_dir}/Processed/MRI_files/03_Fieldmaps/Fieldmap_nback;
	done
	for json_file in *.json; do
		mv -v ${json_file} "${json_file:26:10}.json"
		cp ${json_file:26:10}.json ${Subject_dir}/Processed/MRI_files/03_Fieldmaps/Fieldmap_nback;
	done

	cd ${Subject_dir}/Raw/MRI_files/EP2D_DIFF_5B0_DISTMAP_AP_0043
	rm *.nii.gz*
	rm *.nii
	rm *.json
	#dcm2nii -a n -i y -r n -x n ${Subject_dir}/Raw/MRI_files/EP2D_DIFF_5B0_DISTMAP_AP_0043
	dcm2niix -ba n ${Subject_dir}/Raw/MRI_files/EP2D_DIFF_5B0_DISTMAP_AP_0043

	for nii_file in *.nii; do
		mv -v ${nii_file} "${nii_file:44:10}.nii"
		cp ${nii_file:44:10}.nii ${Subject_dir}/Processed/MRI_files/03_Fieldmaps/Fieldmap_dti;
	done
	for json_file in *.json; do
		mv -v ${json_file} "${json_file:44:10}.json"
		cp ${json_file:44:10}.json ${Subject_dir}/Processed/MRI_files/03_Fieldmaps/Fieldmap_dti;
	done
	
	
	cd ${Subject_dir}/Raw/MRI_files/EP2D_DIFF_5B0_DISTMAP_PA_0044
	rm *.nii.gz*
	rm *.nii
	rm *.json
	#dcm2nii -a n -i y -r n -x n ${Subject_dir}/Raw/MRI_files/EP2D_DIFF_5B0_DISTMAP_PA_0044
	dcm2niix -ba n ${Subject_dir}/Raw/MRI_files/EP2D_DIFF_5B0_DISTMAP_PA_0044
	
	for nii_file in *.nii; do
		mv -v ${nii_file} "${nii_file:44:10}.nii"
		cp ${nii_file:44:10}.nii ${Subject_dir}/Processed/MRI_files/03_Fieldmaps/Fieldmap_dti;
	done
	for json_file in *.json; do
		mv -v ${json_file} "${json_file:44:10}.json"
		cp ${json_file:44:10}.json ${Subject_dir}/Processed/MRI_files/03_Fieldmaps/Fieldmap_dti;
	done
	####################################################################################
	# Resting State
	cd ${Subject_dir}/Raw/MRI_files/RESTSTATE-FMRI_8MIN_0009
	rm *.nii.gz
	rm *.nii
	rm *.json
	#dcm2nii -a n -i y -r n -x n ${Subject_dir}/Raw/MRI_files/RESTSTATE-FMRI_8MIN_0009
	dcm2niix -ba n ${Subject_dir}/Raw/MRI_files/RESTSTATE-FMRI_8MIN_0009

	for nii_file in *.nii; do
		mv -v ${nii_file} "${nii_file:25:14}.nii"
		cp ${nii_file:25:14}.nii ${Subject_dir}/Processed/MRI_files/04_rsfMRI;
	done
	for json_file in *.json*; do
		mv -v ${json_file} "${json_file:25:14}.json"
		cp ${json_file:25:14}.json ${Subject_dir}/Processed/MRI_files/04_rsfMRI;
	done
	#######################################################################################
	## Motor Imagery fMRI Runs
	cd ${Subject_dir}/Raw/MRI_files/FMRI01_RUN1_0017
	rm *.nii.gz*
	rm *.nii*
	rm *.json*

	#dcm2nii -a n -i y -r n -x n ${Subject_dir}/Raw/MRI_files/FMRI01_RUN1_0017
	dcm2niix -ba n ${Subject_dir}/Raw/MRI_files/FMRI01_RUN1_0017
	for nii_file in *.nii*; do
		mv -v ${nii_file} "${nii_file:17:11}.nii"
		cp ${nii_file:17:11}.nii ${Subject_dir}/Processed/MRI_files/05_MotorImagery;
	done
	for json_file in *.json*; do
		mv -v ${json_file} "${json_file:17:11}.json"
		cp ${json_file:17:11}.json ${Subject_dir}/Processed/MRI_files/05_MotorImagery;
	done;

	cd ${Subject_dir}/Raw/MRI_files/FMRI01_RUN2_0019
	rm *.nii.gz*
	rm *.nii*
	rm *.json*
#
	##dcm2nii -a n -i y -r n -x n ${Subject_dir}/Raw/MRI_files/FMRI01_RUN2_0019
	dcm2niix -ba n ${Subject_dir}/Raw/MRI_files/FMRI01_RUN2_0019

	for nii_file in *.nii*; do
		mv -v ${nii_file} "${nii_file:17:11}.nii"
		cp ${nii_file:17:11}.nii ${Subject_dir}/Processed/MRI_files/05_MotorImagery;
	done
	for json_file in *.json*; do
		mv -v ${json_file} "${json_file:17:11}.json"
		cp ${json_file:17:11}.json ${Subject_dir}/Processed/MRI_files/05_MotorImagery;
	done

	#######################################################################################
	## Nback fMRI Runs
	cd ${Subject_dir}/Raw/MRI_files/FMRI02_RUN1_0027
	rm *.nii.gz*
	rm *.nii*
	rm *.json*
	#dcm2nii -a n -i y -r n -x n ${Subject_dir}/Raw/MRI_files/FMRI02_RUN1_0027
	dcm2niix -ba n ${Subject_dir}/Raw/MRI_files/FMRI02_RUN1_0027

	for nii_file in *.nii*; do
		mv -v ${nii_file} "${nii_file:17:11}.nii"
		cp ${nii_file:17:11}.nii ${Subject_dir}/Processed/MRI_files/06_Nback;
	done
	for json_file in *.json*; do
		mv -v ${json_file} "${json_file:17:11}.json"
		cp ${json_file:17:11}.json ${Subject_dir}/Processed/MRI_files/06_Nback;
	done
	

	cd ${Subject_dir}/Raw/MRI_files/FMRI02_RUN2_0029
	rm *.nii.gz
	rm *.nii
	rm *.json
	#dcm2nii -a n -i y -r n -x n ${Subject_dir}/Raw/MRI_files/FMRI02_RUN2_0029
	dcm2niix -ba n ${Subject_dir}/Raw/MRI_files/FMRI02_RUN2_0029

	for nii_file in *.nii*; do
		mv -v ${nii_file} "${nii_file:17:11}.nii"
		cp ${nii_file:17:11}.nii ${Subject_dir}/Processed/MRI_files/06_Nback;
	done
	for json_file in *.json*; do
		mv -v ${json_file} "${json_file:17:11}.json"
		cp ${json_file:17:11}.json ${Subject_dir}/Processed/MRI_files/06_Nback;
	done

	
	cd ${Subject_dir}/Raw/MRI_files/FMRI02_RUN3_0031
	rm *.nii.gz
	rm *.nii
	rm *.json
	#dcm2nii -a n -i y -r n -x n ${Subject_dir}/Raw/MRI_files/FMRI02_RUN3_0031
	dcm2niix -ba n ${Subject_dir}/Raw/MRI_files/FMRI02_RUN2_0029

	for nii_file in *.nii*; do
		mv -v ${nii_file} "${nii_file:17:11}.nii"
		cp ${nii_file:17:11}.nii ${Subject_dir}/Processed/MRI_files/06_Nback;
	done
	for json_file in *.json*; do
		mv -v ${json_file} "${json_file:17:11}.json"
		cp ${json_file:17:11}.json ${Subject_dir}/Processed/MRI_files/06_Nback;
	done

	cd ${Subject_dir}/Raw/MRI_files/FMRI02_RUN4_0033
	rm *.nii.gz
	rm *.nii
	rm *.json
	#dcm2nii -a n -i y -r n -x n ${Subject_dir}/Raw/MRI_files/FMRI02_RUN4_0033
	dcm2niix -ba n ${Subject_dir}/Raw/MRI_files/FMRI02_RUN4_0033
	
	for nii_file in *.nii*; do
		mv -v ${nii_file} "${nii_file:17:11}.nii"
		cp ${nii_file:17:11}.nii ${Subject_dir}/Processed/MRI_files/06_Nback;
	done
	for json_file in *.json*; do
		mv -v ${json_file} "${json_file:17:11}.json"
		cp ${json_file:17:11}.json ${Subject_dir}/Processed/MRI_files/06_Nback;
	done
	#######################################################################################
	## Arterial Spin Labeling 
	cd ${Subject_dir}/Raw/MRI_files/ASL_2D_TRA_FULLBRAIN_0035
	rm *.nii.gz
	rm *.nii
	rm *.json
	#dcm2nii -a n -i y -r n -x n ${Subject_dir}/Raw/MRI_files/ASL_2D_TRA_FULLBRAIN_0035
	dcm2niix -ba n ${Subject_dir}/Raw/MRI_files/ASL_2D_TRA_FULLBRAIN_0035
	for nii_file in *.nii; do
		mv -v ${nii_file} "${nii_file:26:20}.nii"
		cp ${nii_file:26:20}.nii ${Subject_dir}/Processed/MRI_files/07_ASL;
	done
	for json_file in *.json; do
		mv -v ${json_file} "${json_file:26:20}.json"
		cp ${json_file:26:20}.json ${Subject_dir}/Processed/MRI_files/07_ASL;
	done

	cd ${Subject_dir}/Raw/MRI_files/ASL_2D_TRA_FULLBRAIN_0039
	rm *.nii.gz
	rm *.nii
	rm *.json
	#dcm2nii -a n -i y -r n -x n ${Subject_dir}/Raw/MRI_files/ASL_2D_TRA_FULLBRAIN_0039
	dcm2niix -ba n ${Subject_dir}/Raw/MRI_files/ASL_2D_TRA_FULLBRAIN_0039
	
	for nii_file in *.nii; do
		mv -v ${nii_file} "${nii_file:26:20}.nii"
		cp ${nii_file:26:20}.nii ${Subject_dir}/Processed/MRI_files/07_ASL;
	done
	for json_file in *.json; do
		mv -v ${json_file} "${json_file:26:20}.json"
		cp ${json_file:26:20}.json ${Subject_dir}/Processed/MRI_files/07_ASL;
	done
	#######################################################################################
	## Diffusion Weighted Imaging
	cd ${Subject_dir}/Raw/MRI_files/EP2D_DIFF_5B0_DTI_64DIR_0046
	rm *.nii.gz
	rm *.nii
	rm *.json
	rm *.bvec
	rm *.bval
	#dcm2nii -a n -i y -r n -x n ${Subject_dir}/Raw/MRI_files/EP2D_DIFF_5B0_DTI_64DIR_0046
	dcm2niix -ba n ${Subject_dir}/Raw/MRI_files/EP2D_DIFF_5B0_DTI_64DIR_0046

	for nii_file in *.nii; do
		mv -v ${nii_file} "${nii_file:29:17}.nii"
		cp ${nii_file:29:17}.nii ${Subject_dir}/Processed/MRI_files/08_DWI;
	done
	for bvec_file in *.bvec; do
		mv -v ${bvec_file} "${bvec_file:29:17}.bvec"
		cp ${bvec_file:29:17}.bvec ${Subject_dir}/Processed/MRI_files/08_DWI;
	done
	for bval_file in *.bval; do
		mv -v ${bval_file} "${bval_file:29:17}.bval"
		cp ${bval_file:29:17}.bval ${Subject_dir}/Processed/MRI_files/08_DWI;
	done
	for json_file in *.json; do
		mv -v ${json_file} "${json_file:29:17}.json"
		cp ${json_file:29:17}.json ${Subject_dir}/Processed/MRI_files/08_DWI;
	done
	#########################################################################################
	## Perfusion
	cd ${Subject_dir}/Raw/MRI_files/PERFUSION_WEIGHTED_0037
	rm *.nii.gz
	rm *.nii
	rm *.json
	#dcm2nii -a n -i y -r n -x n ${Subject_dir}/Raw/MRI_files/PERFUSION_WEIGHTED_0037
	dcm2niix -ba n ${Subject_dir}/Raw/MRI_files/PERFUSION_WEIGHTED_0037

	i=1
	for nii_file in *.nii; do
		mv -v ${nii_file} "${nii_file:24:20}$((i)).nii"
		cp ${nii_file:24:20}$((i)).nii ${Subject_dir}/Processed/MRI_files/09_Perfusion;
		((i++))
	done
	i=1
	for json_file in *.json; do
		mv -v ${json_file} "${json_file:24:20}$((i)).json"
		cp ${json_file:24:20}$((i)).json ${Subject_dir}/Processed/MRI_files/09_Perfusion;
		((i++))
	done


	cd ${Subject_dir}/Raw/MRI_files/PERFUSION_WEIGHTED_0041
	rm *.nii.gz
	rm *.nii
	rm *.json
	#dcm2nii -a n -i y -r n -x n ${Subject_dir}/Raw/MRI_files/PERFUSION_WEIGHTED_0041
	dcm2niix -ba n ${Subject_dir}/Raw/MRI_files/PERFUSION_WEIGHTED_0041

	i=2
	for nii_file in *.nii; do
		mv -v ${nii_file} "${nii_file:24:20}$((i)).nii"
		cp ${nii_file:24:20}$((i)).nii ${Subject_dir}/Processed/MRI_files/09_Perfusion;
		((i++))
	done
	i=2
	for json_file in *.json; do
		mv -v ${json_file} "${json_file:24:20}$((i)).json"
		cp ${json_file:24:20}$((i)).json ${Subject_dir}/Processed/MRI_files/09_Perfusion;
		((i++))
	done
done