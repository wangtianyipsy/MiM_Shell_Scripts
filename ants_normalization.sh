
subjects=(CrunchPilot03)

ml gcc/5.2.0
ml ants

for SUB in ${subjects[@]}; do


## how did I create Brain_Template ? that was done in SPM
# Will this be replaced by antsMultivariateTemplateConstruction2?

# TO DO:
# Kathleen and Ana suggest an N4 bias correction.. on T1?
# Kathleen suggests tweaking params to deal with atrophy in OA .. assuming params for antsRegistration
# Ants people suggest creating study specific template to deal with atrophy

# No BSpline
#antsMultivariateTemplateConstruction2.sh -d 3 -i 4 -k 1 -f 4x2x1 -s 2x1x0vox -q 30x20x4 -t BSplineSyN -n 1 -m CC -c 0 -r 1 -l 1 -o multivariate_B_ *.nii

# cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/02_T1

# BSpline
# antsMultivariateTemplateConstruction2.sh -d 3 -i 4 -k 1 -f 4x2x1 -s 2x1x0vox -q 30x20x4 -t SyN -n 1  -m CC -c 0 -r 1 -l 1 -o ${SUB}_Brain_ Brain_Template.nii

outputFolder=/ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/10_Ants
t1brain=/ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/02_T1/Brain_Template.nii
template=/ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Code/Ants/_ANTs_c0cTemplate_T1_IXI555_MNI152_GS_brain.nii

antsRegistration --dimensionality 3 --float 0 \
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

#done




#antsTransform

# Kathleen says"normalize:write in SPM. apply the ANTs warp (forward or inverse, depending on which way you went) to all volumes of your fMRI images"