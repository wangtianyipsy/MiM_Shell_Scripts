
# need to find each slictimed and uwarped funcation and run this... 

antsApplyTransforms -d 3 -e 3 -i ra20190401080620_fMRI_LeftFoot_Run1.nii -r ANTs_c0Template_T1_IXI555_MNI152_GS_brain.nii \
-n BSpline -o unwarpedRealigned_slicetimed_warpedToTemplate.nii.gz -t [Template_to_unwarpedRealigned_slicetimed_1InverseWarp.nii.gz] -t [Template_to_unwarpedRealigned_slicetimed_0GenericAffine.mat,1] -v 