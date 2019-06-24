ml fsl

Fieldmap_dir=/ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study/CrunchPilot01/Processed/03_Fieldmaps
#Fieldmap_dir=\ufrc\rachaelseidler\share\FromExternal\Research_Projects_UF\CRUNCH\Pilot_Study\CrunchPilot01\Processed

# NOTE: see me (Kathleen) excel sheet for checking field map parameters. First few subjs differ from later subjs (sigh). 
#head = dicominfo('1003.MR.SEIDLER_GABA-AGING.0023.0001.2019.02.21.09.50.22.389089.183070833.IMA'); 
#
#	# Return the value of the DICOM tag 0019, 1028 
#	# 	This is  48.82799911 = BandwidthPerPixelPhaseEncode
#	head.Private_0019_1028
#
#	# Return the value of the DICOM tag 0019, 1028 
#	# 	This is '96p*96' = MatrixSizePhase
#	head.Private_0051_100b
#	
#	# Calculate effective echo spacing
#	#	This is 0.2133338898  = EffectiveEchoSpacing in seconds
#	ees = XX 
#
## PA FIELD MAP IMAGE WILL BE EXACTLY THE SAME ON THESE PARAMETERS 
#
## NOTE: see my excel sheet for checking field map parameters. First few subjs differ from later subjs (sigh). 
#
##----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----    
## CALCULATE TOTAL READOUT TIME FOR FIELD MAP IMAGES 
#	# FSL version of calculating: 0.0253 seconds
#	totalReadoutTimeFSL = (96-1)*0.2133338898
#
#	# SPM version of calculating; 0.0256 seconds 
#	totalReadoutTimeSPM = 1/3XX

#------------------------------------------------------------------------------------------------------------
# Step 3: Merge AP and PA volumes into one file 
#------------------------------------------------------------------------------------------------------------
cd ${Fieldmap_dir}/Fieldmap_imagery
gunzip *nii.gz*
fslmerge -t AP_PA_merged_imagery fMRIDistMapAP015.nii fMRIDistMapPA011.nii


#------------------------------------------------------------------------------------------------------------
# Remove the most inferior slice from field map; you need even # of slices for topup 
#------------------------------------------------------------------------------------------------------------	

# First, verify that your merged image has an odd number of slices. Dim3 is the number of slices. Here we have 43. Odd number. 
#fslhd AP_PA_merged_imagery.nii

# Split file into individual slices. 
# Should give you 43 files. Named slice0000* - slice00043*   
#fslsplit AP_PA_merged_imagery slice -z 

# Remove slice 0000. 
# (Check what it looks like first to verify; should just be bottom of neck area) 
#rm slice0000.nii.gz
	
# Merge remaining volumes back together. 
#fslmerge -z DistMaps_1003_merged slice0*

# Delete individual slices you previously created. 
#rm slice00*.nii.gz



# check total read out time
echo 0 -1 0 .0203 >> datain.txt 
echo 0  1 0 .0203 >> datain.txt 
#
topup --imain=AP_PA_merged_imagery.nii --datain=datain.txt --fout=my_fieldmap_imagery --iout=se_epi_unwarped_imagery --out=topup_results_imagery
#
#
ml fsl/5.0.8
#
fslchfiletype ANALYZE my_fieldmap_imagery.nii fpm_my_fieldmap_imagery
#




#cd ${Fieldmap_dir}/Fieldmap_nback
#gunzip *nii.gz*
#fslmerge -t AP_PA_merged_nback fMRIDistMapAP025.nii fMRIDistMapPA021.nii
#topup --imain=AP_PA_merged_nback.nii --datain=datain.txt --fout=my_fieldmap_nback --iout=se_epi_unwarped_nback --out=topup_results_nback
#
## check total read out time
#echo 0 -1 0 .0203 >> datain.txt 
#echo 0  1 0 .0203 >> datain.txt 
#
#ml fsl/5.0.8
#
#fslchfiletype ANALYZE my_fieldmap_nback.nii fpm_my_fieldmap_nback
#





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