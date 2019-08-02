

ml gcc/5.2.0
ml ants


outputFolder=/ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/ANTS_Template_Processing_Folder_Crunch
t1brain=/ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/ANTS_Template_Processing_Folder_Local/multivariate_B_template0warp.nii.gz
template=/ufrc/rachaelseidler/tfettrow/Crunch_Code/MR_Templates/_ANTs_c0cTemplate_T1_IXI555_MNI152_GS_brain.nii

antsRegistration --float 0 \
        --output [$outputFolder/Template_to_A_01_,$outputFolder/Template_to_A_01_Warped.nii.gz] \
        --interpolation Linear \
        --winsorize-image-intensities [0.005,0.995] \
        --use-histogram-matching 0 \
        --initial-moving-transform [$t1brain,$template,1] \
        --transform Rigid[0.1] \
        --metric MI[$t1brain,$template,1,32,Regular,0.25] \
        --convergence [1000x500x250x100,1e-6,10] \
        --shrink-factors 8x4x2x1 \
        --smoothing-sigmas 3x2x1x0vox \
        --transform Affine[0.1] \
        --metric MI[$t1brain,$template,1,32,Regular,0.25] \
        --convergence [1000x500x250x100,1e-6,10] \
        --shrink-factors 8x4x2x1 \
        --smoothing-sigmas 3x2x1x0vox \
        --transform SyN[0.1,3,0] \
        --metric CC[$t1brain,$template,1,4] \
        --convergence [100x70x50x20,1e-6,10] \
        --shrink-factors 8x4x2x1 \
        --smoothing-sigmas 3x2x1x0vox

