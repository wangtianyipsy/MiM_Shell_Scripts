#!/bin/bash
# Vincent Koppelmans 2014-01-06
# Create scan Protocol report

# This script removes the variable names from the output, so that the output can be merged with the total table of scan parameters.

# This script makes an overview of all scan parameters that are obtained from the dicom files
# The script must be run in the folder that contains all the individual dicoms of the protocol.
# Behind some variables there are suffixes. These indicate where the variables come from
# come from the headers (varies by manufacturer):
# _P = Philips
# _S = Siemens
# _G = General Electrics (GE)



function usage {
  echo $(tput setaf 1)"This script makes an overview of the scan parameters based on the raw dicom files"$(tput setaf 7)
  echo ""
  echo "Usage: $0" 
  echo $(tput setaf 6)"	MANDATORY"$(tput setaf 7)
  echo "	-N <report $(tput setaf 2)N$(tput setaf 7)ame>"
  echo "	-s $(tput setaf 2)S$(tput setaf 7)orting rule (1=only protocol name) (2=protocol name & series description)"
  echo ""
  echo $(tput setaf 6)"	OPTIONAL"$(tput setaf 7)
  echo "	-h This $(tput setaf 2)h$(tput setaf 7)elp overview" 
  echo "	-i Keep $(tput setaf 2)i$(tput setaf 7)ntermediate files"
  echo "	-l Save $(tput setaf 2)l$(tput setaf 7)og file"  
  echo "	-v Save only $(tput setaf 2)v$(tput setaf 7)alues (no headers)"  

  echo ""
  echo ""
}

while getopts "N:s:ilvh" flag
do
  case "$flag" in
    N)
      NAME=$OPTARG
      ;;
    s)
      SORTING=$OPTARG
      ;;
    i)
      KEEP=1
      ;;
    l)
      LOG=1
      ;;
    v)
      ONLY_VOL=1
      ;;
    h|?)
      usage
      exit 2
      ;;      
  esac
done

if [ -z "${NAME}" ]; then
  echo ""
  echo $(tput setaf 1)"Can't proceed: Report Name is required"$(tput setaf 7)
  echo ""
  usage
  exit 2
fi

if [ -z "${SORTING}" ]; then
  echo ""
  echo $(tput setaf 1)"Can't proceed: Sorting Rule is required"$(tput setaf 7)
  echo ""
  usage
  exit 2
fi


# Save log file: script options
if [[ ${LOG} -eq 1 ]]; then 
	export LOGFILE=/Volumes/Data/tmp/${NAME}_scan_report_log.txt
	touch ${LOGFILE}
	echo "Log file for scan report for: ${NAME}" >> ${LOGFILE}
	echo `date` >> ${LOGFILE}
	echo ${0} ${1} ${2} ${3} ${4} ${5} ${6}>> ${LOGFILE}
	echo "" >> ${LOGFILE}
	echo "" >> ${LOGFILE}
fi	


# Set Environment & Copy Files
echo "			$(tput setaf 2)01.$(tput setaf 7) Copy files"
				export WDIR=/Volumes/Data/tmp/${NAME}
				mkdir -p ${WDIR}/tmp
				export FILE=/Volumes/Data/tmp/${NAME}_dicom_headers_tmp.txt
				export FILE2=/Volumes/Data/tmp/${NAME}_dicom_headers_tmp_2.txt				
				export FINAL=/Volumes/Data/tmp/${NAME}_dicom_headers.txt
				find . -type f -exec cp {} ${WDIR}/tmp \;

# Sorting dicom files in folders based on header information

echo "			$(tput setaf 2)02.$(tput setaf 7) Sort files"
				mkdir -p ${WDIR}/sorted
				dcmsort.sh -D ${WDIR}/tmp -o ${WDIR}/sorted -s ${SORTING} > /dev/null 2>&1



# Log file write: number of files / folders for cleanup
if [[ ${LOG} -eq 1 ]]; then 
	echo "Folders in original raw data folder:" >> ${LOGFILE}
	ls `find . -type d | head -n 2 | tail -n 1` | awk -F_ '{ print $NF, $0 }' | sort -n -k1 >> ${LOGFILE}
	echo ""
	echo "Total number of dicom files: ${NAME}" >> ${LOGFILE}
	find ${WDIR}/sorted -type f | wc -l >> ${LOGFILE}
	echo "Folders before cleanup:" >> ${LOGFILE}
	find ${WDIR}/sorted -type d | sort >> ${LOGFILE}
	echo "" >> ${LOGFILE}
	echo "" >> ${LOGFILE}
fi	

# Deleting folders that may contain dicom files, but that you do not want in your report because they are not the sequences in which you are interested
echo "			$(tput setaf 2)03.$(tput setaf 7) Remove folders:"	
echo "				- MocoSeries"
echo "				- Design"
echo "				- EvaSeries_GLM"
echo "				- Mean_&_t-Maps"
echo "				- ADC"
echo "				- FA"
echo "				- TENSOR"
echo "				- TRACEW"
				for REMOVE in Series Design GLM Maps ADC FA TENSOR TRACEW; do 
					rm -rf ${WDIR}/sorted/*${REMOVE}*
				done


# Save log file: number of files / folders after cleanup
if [[ ${LOG} -eq 1 ]]; then 
	echo "Total number of dicom files: ${NAME}" >> ${LOGFILE}
	find ${WDIR}/sorted -type f | wc -l >> ${LOGFILE}
	echo "Folders after cleanup:" >> ${LOGFILE}
	find ${WDIR}/sorted -type d | sort >> ${LOGFILE}
	echo "" >> ${LOGFILE}
	echo "" >> ${LOGFILE}
fi	


echo "			$(tput setaf 2)04.$(tput setaf 7) Get info"	
				echo Report_name:$'\t'$'\t' ${NAME} >> ${FILE}
				echo "" >> ${FILE}




# Changing the field separator for the for loop (space is no longer a field separator) .
export SAVEIFS=$IFS
export IFS=$(echo -en "\n\b")
				
				for PROTOCOL in `ls ${WDIR}/sorted | head -1`; do 
					cd ${WDIR}/sorted/"${PROTOCOL}" 
					echo "## PROTOCOL DATE ##" >> ${FILE}
					echo "Study_Name"$'\t'$'\t'$'\t' `dcmdump $(ls ${WDIR}/sorted/"${PROTOCOL}" | head -1) | grep \(0008,1030\) | cut -f 2 -d \[ | cut -f 1 -d \]` >> ${FILE}
					echo "Study_Date"$'\t'$'\t'$'\t' `dcmdump $(ls ${WDIR}/sorted/"${PROTOCOL}" | head -1) | grep \(0008,0020\) | cut -f 2 -d \[ | cut -f 1 -d \]` >> ${FILE}
					echo "Study_Time"$'\t'$'\t'$'\t' `dcmdump $(ls ${WDIR}/sorted/"${PROTOCOL}" | head -1) | grep \(0008,0030\) | cut -f 2 -d \[ | cut -f 1 -d \]` >> ${FILE}
					echo "" >> ${FILE}					
					
					echo "## PATIENT INFO ##" >> ${FILE}					
					echo "Patient_Name"$'\t'$'\t' `dcmdump $(ls ${WDIR}/sorted/"${PROTOCOL}" | head -1) | grep \(0010,0010\) | cut -f 2 -d \[ | cut -f 1 -d \]` >> ${FILE}
					echo "Patient_ID"$'\t'$'\t'$'\t' `dcmdump $(ls ${WDIR}/sorted/"${PROTOCOL}" | head -1) | grep \(0010,0020\) | cut -f 2 -d \[ | cut -f 1 -d \]` >> ${FILE}
					echo "Patient_Birth_Date"$'\t' `dcmdump $(ls ${WDIR}/sorted/"${PROTOCOL}" | head -1) | grep \(0010,0030\) | cut -f 2 -d \[ | cut -f 1 -d \]` >> ${FILE}
					echo "Patient_Sex"$'\t'$'\t'$'\t' `dcmdump $(ls ${WDIR}/sorted/"${PROTOCOL}" | head -1) | grep \(0010,0040\) | cut -f 2 -d \[ | cut -f 1 -d \]` >> ${FILE}
					echo "Patient_Age"$'\t'$'\t'$'\t' `dcmdump $(ls ${WDIR}/sorted/"${PROTOCOL}" | head -1) | grep \(0010,1010\) | cut -f 2 -d \[ | cut -f 1 -d \]` >> ${FILE}
					echo "Patient_Height"$'\t'$'\t' `dcmdump $(ls ${WDIR}/sorted/"${PROTOCOL}" | head -1) | grep \(0010,1020\) | cut -f 2 -d \[ | cut -f 1 -d \]` >> ${FILE}
					echo "Patient_Weight"$'\t'$'\t' `dcmdump $(ls ${WDIR}/sorted/"${PROTOCOL}" | head -1) | grep \(0010,1030\) | cut -f 2 -d \[ | cut -f 1 -d \]` >> ${FILE}
					echo "Body_part_examined"$'\t' `dcmdump $(ls ${WDIR}/sorted/"${PROTOCOL}" | head -1) | grep \(0018,0015\) | cut -f 2 -d \[ | cut -f 1 -d \]` >> ${FILE}				
					echo "" >> ${FILE}					
					
					echo "## SCANNER INFO ##" >> ${FILE}					
					echo "MR_Manufacturer"$'\t'$'\t' `dcmdump $(ls ${WDIR}/sorted/"${PROTOCOL}" | head -1) | grep \(0008,0070\) | cut -f 2 -d \[ | cut -f 1 -d \]` >> ${FILE}
					echo "MR_ModelName"$'\t'$'\t' `dcmdump $(ls ${WDIR}/sorted/"${PROTOCOL}" | head -1) | grep \(0008,1090\) | cut -f 2 -d \[ | cut -f 1 -d \]` >> ${FILE}
					echo "MR_Field_Strength"$'\t' `dcmdump $(ls ${WDIR}/sorted/"${PROTOCOL}" | head -1) | grep \(0018,0087\) | cut -f 2 -d \[ | cut -f 1 -d \]` >> ${FILE}
					echo "Transmit_Coil_Name"$'\t' `dcmdump $(ls ${WDIR}/sorted/"${PROTOCOL}" | head -1) | grep \(0018,1251\) | cut -f 2 -d \[ | cut -f 1 -d \]` >> ${FILE}
					echo "MR_Software"$'\t'$'\t'$'\t' `dcmdump $(ls ${WDIR}/sorted/"${PROTOCOL}" | head -1) | grep \(0018,1020\) | cut -f 2 -d \[ | cut -f 1 -d \]` >> ${FILE}
					echo "Institution"$'\t'$'\t'$'\t' `dcmdump $(ls ${WDIR}/sorted/"${PROTOCOL}" | head -1) | grep \(0008,0080\) | cut -f 2 -d \[ | cut -f 1 -d \]` >> ${FILE}
					echo "Address"$'\t'$'\t'$'\t'$'\t' `dcmdump $(ls ${WDIR}/sorted/"${PROTOCOL}" | head -1) | grep \(0008,0081\) | cut -f 2 -d \[ | cut -f 1 -d \]` >> ${FILE}
					echo "" >> ${FILE}	
					echo "" >> ${FILE}	
					echo "" >> ${FILE}							
				done	
								

				for PROTOCOL in `ls ${WDIR}/sorted`; do 
					cd ${WDIR}/sorted/"${PROTOCOL}" 
					echo "---------------------------------------------------------------" >> ${FILE}
					echo "----- PROTOCOL: ${PROTOCOL}" >> ${FILE}
					echo "---------------------------------------------------------------" >> ${FILE}
					echo "Protocol_Name"$'\t'$'\t' `dcmdump $(ls ${WDIR}/sorted/"${PROTOCOL}" | head -1) | grep \(0018,1030\) | cut -f 2 -d \[ | cut -f 1 -d \]` >> ${FILE}
					echo "Series_Description"$'\t' `dcmdump $(ls ${WDIR}/sorted/"${PROTOCOL}" | head -1) | grep \(0008,103e\) | cut -f 2 -d \[ | cut -f 1 -d \]` >> ${FILE}
					echo "Sequence_Name"$'\t'$'\t' `dcmdump $(ls ${WDIR}/sorted/"${PROTOCOL}" | head -1) | grep \(0018,0024\) | cut -f 2 -d \[ | cut -f 1 -d \]` >> ${FILE}
					echo "Series_Date"$'\t'$'\t'$'\t' `dcmdump $(ls ${WDIR}/sorted/"${PROTOCOL}" | head -1) | grep \(0008,0021\) | cut -f 2 -d \[ | cut -f 1 -d \]` >> ${FILE}
					echo "Acquisition_Date"$'\t' `dcmdump $(ls ${WDIR}/sorted/"${PROTOCOL}" | head -1) | grep \(0008,0022\) | cut -f 2 -d \[ | cut -f 1 -d \]` >> ${FILE}
					echo "Content_Date"$'\t'$'\t' `dcmdump $(ls ${WDIR}/sorted/"${PROTOCOL}" | head -1) | grep \(0008,0023\) | cut -f 2 -d \[ | cut -f 1 -d \]` >> ${FILE}							
					echo "Series_Time"$'\t'$'\t'$'\t' `dcmdump $(ls ${WDIR}/sorted/"${PROTOCOL}" | head -1) | grep \(0008,0031\) | cut -f 2 -d \[ | cut -f 1 -d \]` >> ${FILE}
					echo "Acquisition_Time"$'\t' `dcmdump $(ls ${WDIR}/sorted/"${PROTOCOL}" | head -1) | grep \(0008,0032\) | cut -f 2 -d \[ | cut -f 1 -d \]` >> ${FILE}
					echo "Content_Time"$'\t'$'\t' `dcmdump $(ls ${WDIR}/sorted/"${PROTOCOL}" | head -1) | grep \(0008,0033\) | cut -f 2 -d \[ | cut -f 1 -d \]` >> ${FILE}								
					echo "" >> ${FILE}
										
					echo "## SCAN PARAMETERS ##" >> ${FILE}
					echo "Repetition_Time"$'\t'$'\t' `dcmdump $(ls ${WDIR}/sorted/"${PROTOCOL}" | head -1) | grep \(0018,0080\) | cut -f 2 -d \[ | cut -f 1 -d \]` >> ${FILE}
					echo "Echo_Time"$'\t'$'\t'$'\t' `dcmdump $(ls ${WDIR}/sorted/"${PROTOCOL}" | head -1) | grep \(0018,0081\) | cut -f 2 -d \[ | cut -f 1 -d \]` >> ${FILE}
					echo "Number_of_Averages"$'\t' `dcmdump $(ls ${WDIR}/sorted/"${PROTOCOL}" | head -1) | grep \(0018,0083\) | cut -f 2 -d \[ | cut -f 1 -d \]` >> ${FILE}
					echo "Slice_Thickness"$'\t'$'\t' `dcmdump $(ls ${WDIR}/sorted/"${PROTOCOL}" | head -1) | grep \(0018,0050\) | cut -f 2 -d \[ | cut -f 1 -d \]` >> ${FILE}
					echo "Slices_Spacing"$'\t'$'\t' `dcmdump $(ls ${WDIR}/sorted/"${PROTOCOL}" | head -1) | grep \(0018,0088\) | cut -f 2 -d \[ | cut -f 1 -d \]` >> ${FILE}
					echo "Number_of_Slices_S"$'\t' `dcmdump $(ls ${WDIR}/sorted/"${PROTOCOL}" | head -1) | grep \(0019,100a\) | cut -f 2 -d \[ | cut -f 1 -d \] | awk -F \  '{ print $3 }'` >> ${FILE}
					echo "Number_of_Slices_G"$'\t' `dcmdump $(ls ${WDIR}/sorted/"${PROTOCOL}" | head -1) | grep \(0020,1002\) | cut -f 2 -d \[ | cut -f 1 -d \]` >> ${FILE}					
					echo "Number_of_Slices_P"$'\t' `dcmdump $(ls ${WDIR}/sorted/"${PROTOCOL}" | head -1) | grep \(2001,1018\) | cut -f 2 -d \[ | cut -f 1 -d \] | awk -F \  '{ print $3 }'` >> ${FILE}					
					echo "Pixel_Spacing"$'\t'$'\t' `dcmdump $(ls ${WDIR}/sorted/"${PROTOCOL}" | head -1) | grep \(0028,0030\) | cut -f 2 -d \[ | cut -f 1 -d \]` >> ${FILE}
					echo "Field_of_View_S"$'\t'$'\t' `dcmdump $(ls ${WDIR}/sorted/"${PROTOCOL}" | head -1) | grep \(0051,100c\) | cut -f 2 -d \[ | cut -f 1 -d \]` >> ${FILE}
					echo "Field_of_View_P"$'\t'$'\t' `dcmdump $(ls ${WDIR}/sorted/"${PROTOCOL}" | head -1) | grep \(2005,1074\) | awk -F \  '{ print $3 }'`" "`dcmdump $(ls ${WDIR}/sorted/"${PROTOCOL}" | head -1) | grep \(2005,1075\) | awk -F \  '{ print $3 }'`  >> ${FILE}
					echo "Rows"$'\t'$'\t'$'\t'$'\t' `dcmdump $(ls ${WDIR}/sorted/"${PROTOCOL}" | head -1) | grep \(0028,0010\) | cut -f 2 -d \[ | cut -f 1 -d \] | awk -F \  '{ print $3 }'` >> ${FILE}
					echo "Columns"$'\t'$'\t'$'\t'$'\t' `dcmdump $(ls ${WDIR}/sorted/"${PROTOCOL}" | head -1) | grep \(0028,0011\) | cut -f 2 -d \[ | cut -f 1 -d \] | awk -F \  '{ print $3 }'` >> ${FILE}
					echo "Acq._Matrix"$'\t'$'\t'$'\t' `dcmdump $(ls ${WDIR}/sorted/"${PROTOCOL}" | head -1) | grep \(0018,1310\) | cut -f 2 -d \[ | cut -f 1 -d \] | awk -F \  '{ print $3 }'` >> ${FILE}
					echo "Acq._Matrix_S"$'\t'$'\t' `dcmdump $(ls ${WDIR}/sorted/"${PROTOCOL}" | head -1) | grep \(0051,100b\) | cut -f 2 -d \[ | cut -f 1 -d \]` >> ${FILE}
					echo "Phase_Enc_Dir"$'\t'$'\t' `dcmdump $(ls ${WDIR}/sorted/"${PROTOCOL}" | head -1) | grep \(0018,1312\) | cut -f 2 -d \[ | cut -f 1 -d \]` >> ${FILE}
					echo "Flip_Angle"$'\t'$'\t'$'\t' `dcmdump $(ls ${WDIR}/sorted/"${PROTOCOL}" | head -1) | grep \(0018,1314\) | cut -f 2 -d \[ | cut -f 1 -d \]` >> ${FILE}
					echo "" >> ${FILE}	
					echo "" >> ${FILE}	
					echo "" >> ${FILE}	
				done


# If -v flag is chosen, then remove the 1st column (with the variable names):

if [ -z ${ONLY_VOL} ]; then
	echo "			$(tput setaf 2)05.$(tput setaf 7) Keep variable names"
				cp ${FILE} ${FILE2}
elif [[ ${ONLY_VOL} -eq 1 ]]; then 
	echo "			$(tput setaf 2)05.$(tput setaf 7) Remove variable names"	
				awk -F $'\t' '{ print $2,$3,$4,$5 }' ${FILE} | sed -e 's/^[[:space:]]*//' > ${FILE2}
fi


echo "			$(tput setaf 2)06.$(tput setaf 7) Clean up file"	
				sed \
				-e 's/(0010,0030) DA (no value available)                     #   0, 0 PatientBirthDate//g' \
				-e 's/(0010,0040) CS (no value available)                     #   0, 0 PatientSex//g' \
				-e 's/(0018,0024) SH (no value available)                     #   0, 0 SequenceName//g' \
				${FILE2} > ${FINAL}
				


# Only discard intermediate files if the -i flag is not used:
if [ -z ${KEEP} ]; then
echo "			$(tput setaf 2)07.$(tput setaf 7) Remove temporary files"
					rm -rf ${WDIR}
					rm -f ${FILE}
					rm -f ${FILE2}										
					echo ""
					echo ""
fi				

# Changing back the field separator for the for loop
IFS=$SAVEIFS

exit