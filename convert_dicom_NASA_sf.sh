#!/bin/bash

# dd 10 November 2016, Vincent Koppelmans
# This script converts raw NASA MRI (dicom) data into Nifti files and sorts the data into folders
# This script uses Chris Roden's dcm2nii (must be in path)
# This script uses my create_scan_report.sh script

# 10-11-2016: Crops and reoriented files are standard for structural scans
# written. I do not use this. Disabled (-r N -x N)
# 16-01-2014: dcm2nii * replaced with dcm2nii <folder>. Because of this you no longer have the problem with "argument list too long" 

clear
printf '\033[8;40;130t'

function usage {
  echo $(tput setaf 1)"This script converts raw NASA MRI (dicom) data into Nifti files and sorts the data into folders"$(tput setaf 7)
  echo ""
  echo "Usage: $0" 
  echo $(tput setaf 6)"	MANDATORY"$(tput setaf 7)
  echo "	-S $(tput setaf 2)S$(tput setaf 7)ubject ID"
  echo "	-s $(tput setaf 2)s$(tput setaf 7)essie nummer"
  echo ""
  echo $(tput setaf 6)"	OPTIONAL"$(tput setaf 7)
  echo "	-h This $(tput setaf 2)h$(tput setaf 7)elp overview" 
  echo "	-d $(tput setaf 2)D$(tput setaf 7) design/tmaps/evaseries folders before conversion"  
  echo "	-i Keep $(tput setaf 2)i$(tput setaf 7)ntermediate files"
  echo "	-l Save $(tput setaf 2)l$(tput setaf 7)og file en dicom header report"   

  echo ""
  echo ""
}

while getopts "S:s:dilh" flag
do
  case "$flag" in
    S)
      SUB_ID=$OPTARG
      ;;
    s)
      SSN_ID=$OPTARG
      ;;
    d)
      REMOVE=1
      ;;      
    i)
      KEEP=1
      ;;
    l)
      LOG=1
      ;;
    h|?)
      usage
      exit 2
      ;;      
  esac
done

if [ -z "${SUB_ID}" ]; then
  echo ""
  echo $(tput setaf 1)"Can't proceed: Subject ID is required"$(tput setaf 7)
  echo ""
  usage
  exit 2
fi

if [ -z "${SSN_ID}" ]; then
  echo ""
  echo $(tput setaf 1)"Can't proceed: Session number is required"$(tput setaf 7)
  echo ""
  usage
  exit 2
fi


# Set environment
export ORIGINAL=${PWD}
export INDIR=/Volumes/Data/tmp/NASA_raw/original_dicom
export OUTDIR=/Volumes/Data/tmp/NASA_raw/nifti
mkdir -p ${INDIR}
mkdir -p ${OUTDIR}/${SUB_ID}/${SSN_ID}

export WDIR=${OUTDIR}/${SUB_ID}/${SSN_ID}
echo ""
echo ""
echo ""
echo "	$(tput setaf 6)""Running script:""$(tput sgr0)"
echo "	$(tput setaf 4)01.$(tput sgr0) Copying original files..."
echo "	    >> $(tput smul)`find "${ORIGINAL}" -type f | wc -l | sed 's/\ //g'`$(tput rmul) dicom files found (`find ${ORIGINAL} -type d -maxdepth 1 -print0 | xargs -0 du -sh | head -n 1 | awk '{ print $1 }'`)"


# Copying dicom files (ima files and files without extension) .
if [[ ${REMOVE} -eq 1 ]]; then
find "${ORIGINAL}" \! -name '*\.*' -type f \
! -path "${ORIGINAL}/*ADC*" \
! -path "${ORIGINAL}/*COLFA*" \
! -path "${ORIGINAL}/*FA*" \
! -path "${ORIGINAL}/*TENSOR*" \
! -path "${ORIGINAL}/*TRACEW*" \
! -path "${ORIGINAL}/*MEAN_T-MAPS*" \
! -path "${ORIGINAL}/*EVASERIES*" \
! -path "${ORIGINAL}/*BAS_MOCOSERIES*" \
! -path "${ORIGINAL}/*ACT_MOCOSERIES*" \
! -path "${ORIGINAL}/*DESIGN*" | \
xargs -I {} cp {} "${INDIR}"

find "${ORIGINAL}" -iname '*.ima' -type f \
! -path "${ORIGINAL}/*ADC*" \
! -path "${ORIGINAL}/*COLFA*" \
! -path "${ORIGINAL}/*FA*" \
! -path "${ORIGINAL}/*TENSOR*" \
! -path "${ORIGINAL}/*TRACEW*" \
! -path "${ORIGINAL}/*MEAN_T-MAPS*" \
! -path "${ORIGINAL}/*EVASERIES*" \
! -path "${ORIGINAL}/*BAS_MOCOSERIES*" \
! -path "${ORIGINAL}/*ACT_MOCOSERIES*" \
! -path "${ORIGINAL}/*DESIGN*" | \
xargs -I {} cp {} "${INDIR}"

else \
find "${ORIGINAL}" \! -name '*\.*' -type f | xargs -I {} cp {} "${INDIR}"
find "${ORIGINAL}" -iname '*.ima' -type f | xargs -I {} cp {} "${INDIR}"
fi

echo "	    >> $(tput smul)`ls "${INDIR}" | wc -l | sed 's/\ //g'`$(tput rmul) dicom files copied (`find ${INDIR} -type d -maxdepth 1 -print0 | xargs -0 du -sh | head -n 1 | awk '{ print $1 }'`)"


# Create folders
mkdir -p ${WDIR}/01_Localizer 
mkdir -p ${WDIR}/02_T1 
mkdir -p ${WDIR}/03_Rest_fcMRI
mkdir -p ${WDIR}/04_VEMP
mkdir -p ${WDIR}/05_Tapping
mkdir -p ${WDIR}/06_Adaptation
mkdir -p ${WDIR}/07_SWM
mkdir -p ${WDIR}/08_Foot_tapping
mkdir -p ${WDIR}/09_DWI
mkdir -p ${WDIR}/10_T2	


# DCM2NII
cd "${INDIR}"

						echo -e "	$(tput setaf 4)02.$(tput sgr0) Converting DICOM files to Nifti files... \t\t"$(tput setaf 8)"(${INDIR})""$(tput sgr0)"
						dcm2nii -a n -i y -r n -x n "${INDIR}" >> ${WDIR}/dcm2nii_log_${SUB_ID}_${SSN_ID}.txt
						wait
						echo -e "	$(tput setaf 4)03.$(tput sgr0) Moving converted files to new directory... \t\t"$(tput setaf 8)"(${OUTDIR}: /${SUB_ID}/${SSN_ID})""$(tput sgr0)"
						mv -n ${INDIR}/*localizer* ${WDIR}/01_Localizer/ 2>> ${WDIR}/move_error_${SUB_ID}_${SSN_ID}.txt
						mv -n ${INDIR}/*mprage* ${WDIR}/02_T1/ 2>> ${WDIR}/move_error_${SUB_ID}_${SSN_ID}.txt
						mv -n ${INDIR}/*RESTING* ${WDIR}/03_Rest_fcMRI/ 2>> ${WDIR}/move_error_${SUB_ID}_${SSN_ID}.txt
						mv -n ${INDIR}/*66MEASURMENTS* ${WDIR}/04_VEMP/ 2>> ${WDIR}/move_error_${SUB_ID}_${SSN_ID}.txt
						mv -n ${INDIR}/*71MEASURMENTS* ${WDIR}/05_Tapping/ 2>> ${WDIR}/move_error_${SUB_ID}_${SSN_ID}.txt
						mv -n ${INDIR}/*39MEASURMENTS* ${WDIR}/06_Adaptation/ 2>> ${WDIR}/move_error_${SUB_ID}_${SSN_ID}.txt
						mv -n ${INDIR}/*70MEASURMENTS* ${WDIR}/06_Adaptation/ 2>> ${WDIR}/move_error_${SUB_ID}_${SSN_ID}.txt
						mv -n ${INDIR}/*52MEASURMENTS* ${WDIR}/07_SWM/ 2>> ${WDIR}/move_error_${SUB_ID}_${SSN_ID}.txt
						mv -n ${INDIR}/*67MEASURMENTS* ${WDIR}/07_SWM/ 2>> ${WDIR}/move_error_${SUB_ID}_${SSN_ID}.txt
						mv -n ${INDIR}/*50MEASURMENTS* ${WDIR}/08_Foot_Tapping/ 2>> ${WDIR}/move_error_${SUB_ID}_${SSN_ID}.txt
						mv -n ${INDIR}/*diffmd* ${WDIR}/09_DWI/ 2>> ${WDIR}/move_error_${SUB_ID}_${SSN_ID}.txt
						mv -n ${INDIR}/*t2spcsagp2* ${WDIR}/10_T2/ 2>> ${WDIR}/move_error_${SUB_ID}_${SSN_ID}.txt
						
						mv -n ${INDIR}/*t1mprsag* ${WDIR}/02_T1/ 2>> ${WDIR}/move_error_${SUB_ID}_${SSN_ID}.txt
						mv -n ${INDIR}/*ep2dboldmoco164* ${WDIR}/03_Rest_fcMRI/ 2>> ${WDIR}/move_error_${SUB_ID}_${SSN_ID}.txt
						mv -n ${INDIR}/*ep2dboldmoco66* ${WDIR}/04_VEMP/ 2>> ${WDIR}/move_error_${SUB_ID}_${SSN_ID}.txt
						mv -n ${INDIR}/*ep2dboldmoco71* ${WDIR}/05_Tapping/ 2>> ${WDIR}/move_error_${SUB_ID}_${SSN_ID}.txt
						mv -n ${INDIR}/*ep2dboldmoco39* ${WDIR}/06_Adaptation/ 2>> ${WDIR}/move_error_${SUB_ID}_${SSN_ID}.txt
						mv -n ${INDIR}/*ep2dboldmoco70* ${WDIR}/06_Adaptation/ 2>> ${WDIR}/move_error_${SUB_ID}_${SSN_ID}.txt
						mv -n ${INDIR}/*ep2dboldmoco52* ${WDIR}/07_SWM/ 2>> ${WDIR}/move_error_${SUB_ID}_${SSN_ID}.txt
						mv -n ${INDIR}/*ep2dboldmoco67* ${WDIR}/07_SWM/ 2>> ${WDIR}/move_error_${SUB_ID}_${SSN_ID}.txt
						mv -n ${INDIR}/*ep2dboldmoco50* ${WDIR}/08_Foot_Tapping/ 2>> ${WDIR}/move_error_${SUB_ID}_${SSN_ID}.txt
						mv -n ${INDIR}/*diffmd* ${WDIR}/09_DWI/ 2>> ${WDIR}/move_error_${SUB_ID}_${SSN_ID}.txt
						
						
						
						# Check for duplicates, rename them, move them, put out an error
						cd ${INDIR}
							Nii=`ls *.nii.gz 2> /dev/null`
							if [[ -z ${Nii} ]]; then echo ""$(tput setaf 2)"	    >>"$(tput sgr0)" No Duplicates found, proceeding to 05.";
							else 
								echo ""$(tput setaf 9)"	    >>"$(tput sgr0)" Duplicate files found, check your output carefully!!"
								for duplicate in `ls *.nii.gz`; do 
								mv ${INDIR}/${duplicate} ${INDIR}/DUPLICATE_${duplicate}
								done 
								
								echo -e "	$(tput setaf 4)04.$(tput sgr0) Moving duplicate files to new directory... \t\t"$(tput setaf 244)"(${INDIR})""$(tput setaf 15)"
								mv -n ${INDIR}/*localizer* ${WDIR}/01_Localizer/ 2>> ${WDIR}/move_error_${SUB_ID}_${SSN_ID}.txt
								mv -n ${INDIR}/*mprage* ${WDIR}/02_T1/ 2>> ${WDIR}/move_error_${SUB_ID}_${SSN_ID}.txt
								mv -n ${INDIR}/*RESTING* ${WDIR}/03_Rest_fcMRI/ 2>> ${WDIR}/move_error_${SUB_ID}_${SSN_ID}.txt
								mv -n ${INDIR}/*66MEASURMENTS* ${WDIR}/04_VEMP/ 2>> ${WDIR}/move_error_${SUB_ID}_${SSN_ID}.txt
								mv -n ${INDIR}/*71MEASURMENTS* ${WDIR}/05_Tapping/ 2>> ${WDIR}/move_error_${SUB_ID}_${SSN_ID}.txt
								mv -n ${INDIR}/*39MEASURMENTS* ${WDIR}/06_Adaptation/ 2>> ${WDIR}/move_error_${SUB_ID}_${SSN_ID}.txt
								mv -n ${INDIR}/*70MEASURMENTS* ${WDIR}/06_Adaptation/ 2>> ${WDIR}/move_error_${SUB_ID}_${SSN_ID}.txt
								mv -n ${INDIR}/*52MEASURMENTS* ${WDIR}/07_SWM/ 2>> ${WDIR}/move_error_${SUB_ID}_${SSN_ID}.txt
								mv -n ${INDIR}/*67MEASURMENTS* ${WDIR}/07_SWM/ 2>> ${WDIR}/move_error_${SUB_ID}_${SSN_ID}.txt
								mv -n ${INDIR}/*50MEASURMENTS* ${WDIR}/08_Foot_Tapping/ 2>> ${WDIR}/move_error_${SUB_ID}_${SSN_ID}.txt
								mv -n ${INDIR}/*diffmd* ${WDIR}/09_DWI/ 2>> ${WDIR}/move_error_${SUB_ID}_${SSN_ID}.txt
								mv -n ${INDIR}/*t2spcsagp2* ${WDIR}/10_T2/ 2>> ${WDIR}/move_error_${SUB_ID}_${SSN_ID}.txt			
								
								mv -n ${INDIR}/*t1mprsag* ${WDIR}/02_T1/ 2>> ${WDIR}/move_error_${SUB_ID}_${SSN_ID}.txt
								mv -n ${INDIR}/*ep2dboldmoco164* ${WDIR}/03_Rest_fcMRI/ 2>> ${WDIR}/move_error_${SUB_ID}_${SSN_ID}.txt
								mv -n ${INDIR}/*ep2dboldmoco66* ${WDIR}/04_VEMP/ 2>> ${WDIR}/move_error_${SUB_ID}_${SSN_ID}.txt
								mv -n ${INDIR}/*ep2dboldmoco71* ${WDIR}/05_Tapping/ 2>> ${WDIR}/move_error_${SUB_ID}_${SSN_ID}.txt
								mv -n ${INDIR}/*ep2dboldmoco39* ${WDIR}/06_Adaptation/ 2>> ${WDIR}/move_error_${SUB_ID}_${SSN_ID}.txt
								mv -n ${INDIR}/*ep2dboldmoco70* ${WDIR}/06_Adaptation/ 2>> ${WDIR}/move_error_${SUB_ID}_${SSN_ID}.txt
								mv -n ${INDIR}/*ep2dboldmoco52* ${WDIR}/07_SWM/ 2>> ${WDIR}/move_error_${SUB_ID}_${SSN_ID}.txt
								mv -n ${INDIR}/*ep2dboldmoco67* ${WDIR}/07_SWM/ 2>> ${WDIR}/move_error_${SUB_ID}_${SSN_ID}.txt
								mv -n ${INDIR}/*ep2dboldmoco50* ${WDIR}/08_Foot_Tapping/ 2>> ${WDIR}/move_error_${SUB_ID}_${SSN_ID}.txt
								mv -n ${INDIR}/*diffmd* ${WDIR}/09_DWI/ 2>> ${WDIR}/move_error_${SUB_ID}_${SSN_ID}.txt								
												
							fi		
	
	
# INCLUDE SUBJECT-ID and SCAN-SESSION-ID in the FILENAMES
cd ${WDIR}
echo -e "	$(tput setaf 4)05.$(tput sgr0) Renaming files: including SUBJECT ID and TIME POINT..."
for SCAN_DIR in `ls -p | grep \/ | sed 's/\///g'`; do
	cd ${WDIR}/${SCAN_DIR}
		
	for SCAN in `ls`; do
	mv ${SCAN} ${SUB_ID}_${SSN_ID}_${SCAN}
	done 
done


# Create scan report if the -l flag is used:
if [[ ${LOG} -eq 1 ]]; then
	echo -e "	$(tput setaf 4)06.$(tput sgr0) Creating scan protocol report..."
	echo ""
	echo ""	 
	cd ${ORIGINAL}
	bash /Users/Vincent/Scripts/MRI/create_scan_protocol_report.sh -N ${SUB_ID}_${SSN_ID} -s 2 -l -v
fi
		
		
# Only discard intermediate files if the -i flag is not used:
echo -e "	$(tput setaf 4)07.$(tput sgr0) Removing temporary files..."	
if [ -z ${KEEP} ]; then
	rm -rf ${INDIR}
fi

echo ""
echo ""
echo ""		
cd ${WDIR}
open .
exit