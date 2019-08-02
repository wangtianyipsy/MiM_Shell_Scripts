ml fsl

Fieldmap_dir=/ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study/CrunchPilot01/Processed/03_Field_maps

DWI_dir=/ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study/CrunchPilot01/Processed/08_DWI

# need to move datain, mask, and index file to DWI folder


## data is the dwi data ??

# update file names
eddy --imain=data --mask= this needs to be fsl maps --acqp=datain.txt --index=index.txt --bvecs=bvecs --bvals=bvals --topup=my_topup_results --out=eddy_corrected_data

