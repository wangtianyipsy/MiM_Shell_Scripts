
Study_dir=/blue/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/MiM_Data

cd ${Study_dir}/ROIs/AAL_Labeling_Files

#convert AAL_1mm to 2mm
ml fsl
flirt -in AAL3_1mm.nii -ref AAL3_1mm.nii -out AAL3_2mm -applyisoxfm 2
gunzip -f *nii.gz
#coregister AAL_2mm to MNI_2mm
ml gcc/5.2.0
ml ants


antsRegistration -d 3 -o [warpToMNIParams,warpToMNIEstimate.nii] -r [ MNI_2mm.nii, AAL3_2mm.nii,1] -m MI[ MNI_2mm.nii, AAL3_2mm.nii,1,32,Regular,0.25] -t Translation[0.1] -c 0 -s 0 -f 1

# antsRegistration --dimensionality 3 --float 0 \
# 					    --output [warpToMNIParams,warpToMNIEstimate.nii] \
# 					    --transform Translation[0.1] \
# 					    --metric MI[MNI_2mm.nii,AAL3_2mm.nii,1,32,Regular,0.25] \
	
# antsRegistration --dimensionality 3 --float 0 \
# 					    --output [warpToMNIParams,warpToMNIEstimate.nii] \
# 					    --interpolation Linear \
# 					    --winsorize-image-intensities [0.005,0.995] \
# 					    --use-histogram-matching 0 \
# 					    --initial-moving-transform [MNI_2mm.nii,AAL3_2mm.nii,1] \
# 					    --transform Rigid[0.1] \
# 					    --metric MI[MNI_2mm.nii,AAL3_2mm.nii,1,32,Regular,0.25] \
					    #--convergence [1000x500x250x100,1e-6,10] \
					    #--shrink-factors 8x4x2x1 \
					    #--smoothing-sigmas 3x2x1x0vox
			
antsApplyTransforms -d 3 -e 3 -i AAL3_2mm.nii -r MNI_2mm.nii \
-n BSpline -o warpedToMNI_AAL3_2mm.nii -t [warpToMNIParams0GenericAffine.mat,1] -v