#############################################################################################################
# 
# Processing needed to prepare fMRI field map with oppisite phase encoded EPIs 
# 	KH 
# 	6/3/19
# 	EXAMPLE FROM UF DATA
#	Refs = https://lcni.uoregon.edu/kb-articles/kb-0003 and FieldMap toolbox manual (green help button in GUI) 
#
#############################################################################################################

#------------------------------------------------------------------------------------------------------------
# Step 1 & 2: Calculate effective echo spacing and total readout time 
#------------------------------------------------------------------------------------------------------------
# Load matlab 
ml matlab; matlab –nodesktop –nosplash 

# IN MATLAB: 
# FIRST, FOR THE AP IMAGE: 
	# Start in appropriate directory 
	cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/GABA_Aging_KH/_DATA/_GABA_Aging_Data/1003/02_MRI/01_DICOM/1003/1003_1003/SEIDLER_GABA-AGING_20190221_081547_041000/FMRI-DISTMAP_AP_0023
	
	# Pull header info from the DICOM file for the field map 
	head = dicominfo('1003.MR.SEIDLER_GABA-AGING.0023.0001.2019.02.21.09.50.22.389089.183070833.IMA'); 

	# Return the value of the DICOM tag 0019, 1028 
	# 	This is 39.0630 = BandwidthPerPixelPhaseEncode
	head.Private_0019_1028

	# Return the value of the DICOM tag 0019, 1028 
	# 	This is '80p*80' = MatrixSizePhase
	head.Private_0051_100b
	
	# Calculate effective echo spacing
	#	This is 3.2000e-04 = EffectiveEchoSpacing in seconds
	ees = 1/(39.0630*80) 

# PA FIELD MAP IMAGE WILL BE EXACTLY THE SAME ON THESE PARAMETERS 

# NOTE: see my excel sheet for checking field map parameters. First few subjs differ from later subjs (sigh). 

#----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----    
# CALCULATE TOTAL READOUT TIME FOR FIELD MAP IMAGES 
	# FSL version of calculating: 0.0253 seconds
	totalReadoutTimeFSL = (80-1)*3.2000e-04

	# SPM version of calculating; 0.0256 seconds 
	totalReadoutTimeSPM = 1/39.0630
	
#----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----   
# NEXT, DO THE SAME FOR THE ACTUAL FMRI IMAGES 
# (You'll use this later in FieldMap Toolbox) 
	# Start in appropriate directory 
	cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/GABA_Aging_KH/_DATA/_GABA_Aging_Data/1003/02_MRI/01_DICOM/1003/1003_1003/SEIDLER_GABA-AGING_20190221_081547_041000/FMRI_LEFTFOOT_RUN1_0019

	# Pull header info from the DICOM file for the field map 
	head = dicominfo('1003.MR.SEIDLER_GABA-AGING.0019.0001.2019.02.21.09.34.33.998844.183027821.IMA'); 

	# Return the value of the DICOM tag 0019, 1028 
	# 	This is 42.8280 = BandwidthPerPixelPhaseEncode
	head.Private_0019_1028

	# Return the value of the DICOM tag 0019, 1028 
	# 	This is '96*96' = MatrixSizePhase
	head.Private_0051_100b
	
	# Calculate effective echo spacing
	#	This is 2.4322e-04 = EffectiveEchoSpacing in seconds 
	#	In ms for FieldMap Toolbox, this = 0.24322 milliseconds
	ees = 1/(42.828*96)

#----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----    
# CALCULATE TOTAL READOUT TIME FOR fMRI IMAGES 
	# FSL version of calculating: 0.0231 seconds = 23.1 ms
	totalReadoutTimeFSL = (96-1)*2.4322e-04

	# SPM version of calculating; 0.0233 seconds = 23.3 ms 
	totalReadoutTimeSPM = 1/42.8280
	
#------------------------------------------------------------------------------------------------------------
# Step 3: Merge AP and PA volumes into one file 
#------------------------------------------------------------------------------------------------------------
# IN FSL: 
# Change to appropriate directory 
cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/GABA_Aging_KH/fieldMap_example

# Load FSL  
ml fsl 

# Merge the two maps. Will save new file into your current directory.   
fslmerge -t DistMaps_1003_merged 1003_fMRI-DistMap_AP.nii 1003_fMRI-DistMap_PA.nii

#------------------------------------------------------------------------------------------------------------
# Step 4: Remove the most inferior slice from field map; you need even # of slices for topup 
#------------------------------------------------------------------------------------------------------------	

# AP/ PA images have 43 slices. You want 42. 

# First, verify that your merged image has an odd number of slices. Dim3 is the number of slices. Here we have 43. Odd number. 
fslhd DistMaps_1003_merged.nii.gz

# Split file into individual slices. 
# Should give you 43 files. Named slice0000* - slice00043*   
fslsplit DistMaps_1003_merged slice -z 

# Remove slice 0000. 
# (Check what it looks like first to verify; should just be bottom of neck area) 
rm slice0000.nii.gz
	
# Merge remaining volumes back together. 
fslmerge -z DistMaps_1003_merged slice0*

# Delete individual slices you previously created. 
rm slice00*.nii.gz


#------------------------------------------------------------------------------------------------------------
# Step 5: Create GABA aging specific acq parameter file called datain.txt 
#------------------------------------------------------------------------------------------------------------	
# This is a text file with four columns: 
#	-The first three columns indicate the phase encode direction. 
#	-The fourth is the total readout time in seconds. 
#	-These parameters are for the FIELD MAP, not for the fMRI acquisition: 
#	-File format: x | y | z | phase encoding directions | total readout time(s)
# 		-1 = anterior to posterior; +1 = posterior to anterior  

echo 0 -1 0 .0253 >> datain.txt 
echo 0  1 0 .0253 >> datain.txt 
	
#------------------------------------------------------------------------------------------------------------
# Step 6: Run top-up to create the field map 
#------------------------------------------------------------------------------------------------------------	
	
# Run topup 
topup --imain=DistMaps_1003_merged_42slices --datain=acq_params.txt  --config=b02b0.cnf --fout=B0_fieldmapHz --iout=se_images_unwarped

# The fieldmap that is returned will be in units of Hz, which is what you want for the FieldMap toolbox anyways
# Don't need to convert to radians 
	
#------------------------------------------------------------------------------------------------------------
# Step 7: Convert your field map image into ANALYZE format (.img/.hdr) 
#------------------------------------------------------------------------------------------------------------

# Load an older version of FSL, because the newest version of FSL doesn't allow ANALYZE as output format 
ml fsl/5.0.8

# Make a .img / .hdr version of your field map. 
# Also add the prefix "fpm" to it because this is what the FieldMap toolbox looks for 
fslchfiletype ANALYZE B0_fieldmapHz.nii fpm_B0_fieldmapHz
	
#------------------------------------------------------------------------------------------------------------
# Step 8: Use FieldMap toolbox in SPM 
#------------------------------------------------------------------------------------------------------------
	
# Open FieldMap toolbox 
# 	(We already did this: if your fieldmap was created using method 2, you will have to use FSL & topup to calculate a field map as discussed above.)  
#	See LCNI website, but also green "Help" button on FieldMap toolbox. 

# 	1. Load field map using button "Precalculated" -> Load. Select the "fpm" ANALYZE format field map file. 
#		-In that case, you will need to load a precalculated fieldmap using the obvious button. 
#		-The fieldmap needs to already be in Hz, must have a filename starting with "fpm", and must be in a NIFTI pair file format.
#		- Loading a precalculated field map: 
#			-Alternatively, it is also possible to load a precalculated unwrapped field map (fpm_*.img). 
#			-This should be a single image volume with units of Hz and be in Analyze format.
#			-Once calculated or loaded, the field map is displayed in a figure window and the field at different points can be explored.

#	2.  Convert the field map in Hz to a voxel displacement map (VDM) 
#	 	-The second part of the toolbox deals with converting the field map (in Hz) to a voxel displacement map, VDM, in units of voxels. 
#		-This requires a few parameters to be set and works as follows:
#			1) The field map is multiplied by the total EPI readout time (in ms) of the EPI image to be unwarped, resulting in a VDM.
#					-This is the total epi readout time in ms for the BOLD series you are correcting, NOT the total readout time from the field map acquisition.
#			 		-This is specified by pm_def.TOTAL_EPI_READOUT_TIME (eg typically 10s of ms).
#					-For GABA Aging, this is 23.1 ms. 
#					-Thus enter in 23.1 ms in the entry box. 
#
#			2) "EPI based fieldmap" should be "yes" (????????) 
#					-The toolbox must know if the field map is based on an EPI or non-EPI acquisition. 
#					-If using an EPI-based field map, the VDM must be inverted since the field map was acquired in warped space. 
#					-This is specified by pm_def.EPI_BASED_FIELDMAPS = 1 or 0.
#
#			3) Polarity of phase encode blips...depends... try both ways initially 
#					-LCNI: Polarity of the blips depends not only on your acquisition but also on how your data was converted to NIFTI, so it could be either + or - ve.
#						   The easiest thing to do is to try it both ways.
#					-FieldMap Manual: The VDM is multiplied by +/-1 to indicate whether the K-space traversal for the data acquisition has a +ve or -ve blip direction.
#						   This will ensure that the unwarping is performed in the correct direction and is specified by pm_def.K_SPACE_TRAVERSAL_BLIP_DIR = +/- 1.
#
#			4) "Apply jacobian modulation" should be "no". (probably try both ways to start) 
#					-FieldMap Manual: There is an option to apply Jacobian Modulation to the unwarped EPI image. 
#							This modulates the intensity of the unwarped image so that in regions where voxels were compressed, the intensity is decresed and where voxels 
#							were stretched, the intensities are increased slightly. The modulation involves multiplying the unwarped EPI by 1 + the 1-d derivative of the VDM in the phase direction.
#							An intensity adjustment of this nature may improve the coregistration results between an unwarped EPI and an undistorted image.
#
# 	3. Load in an EPI fMRI image. 
#		-The resulting VDM is used to unwarp a selected EPI. 
#		-The warped and the unwarped EPI are displayed in the figure window so that the effects of the unwarping can be inspected.
# 		-When any of the above conversion parameters are changed or a new EPI is selected, a new VDM is created and saved with the filename vdm_NAME-OF-FIRST-INPUT-IMAGE.img.
#		-Any previous copy of the .img file is overwritten, but the corresponding .mat file is retained. 
#		-It is done this way because the VDM may have already been coregiseterd to the EPI (as described below).
#		-Then, for an EPI-based VDM, the match between the VDM and the EPI will still be valid even if any of the above parameters have been changed. 
#		-If the VDM is non-EPI-based and any of the above parameters are changed, the match between the VDM and the EPI may no longer be valid. 
#		-In this case a warning is given to the user that it may be necessary to perform the coregistration again. 


# QUESTIONS / TO DO: 
#	-Need to play with settings, take screenshots, & figure out what's optimal. 
#		-Revisit the FieldMap instructions. 
#	-Need to figure out whether to use the FieldMap toolbox button to coregister fMRI run to VDM. Button = Match VDM to EPI. 
#		-If so, when to press this button? 
#	-Do Realign & Unwarp. 
#		-Put in the VDM here. 
#	-Make a clean example. 

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	