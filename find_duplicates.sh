#!/bin/bash
# find duplicates in a list of directories
#  model https://github.com/NorwegianVeterinaryInstitute/Diverse_ISAV/blob/main/scripts/DEL_HPR/extract_reads.sh 
# /run/media/evezeyl/Elements/GITS/maintenance/find_duplicates.sh


############################################################
#                         Help                             #
############################################################
# https://www.redhat.com/sysadmin/arguments-options-bash-scripts
Help() {
   # Display Help
   echo "Finds duplicates in a list of directory (one or several)"
   echo
   echo "Syntax: archives_maintenance.sh -[d|h]"
   echo "options:"
   echo "d     directory or list of directories, if several directories are separated by space"
   echo "h     Print this Help."
   echo
}
# setting variables
mydirectory="mydirectory"
# Getting options
while getopts "d:h" option
  do
   case $option in
     d) # mydirectory
     mydirectory=$OPTARG;;
     h) # display Help
      Help
      exit;;
    \?) # Invalid option
    echo "Error: Invalid option"
      Help
      exit;;
   esac
done

############################################################
#                       Functions definitions              #
############################################################


find_duplicates () {
  # find duplicated files in a set of directories
  iso_date=$(date -I)
  fdupes -r1A ${mydirectory} >> ${iso_date}_identical.txt 
}


############################################################
#                       Running script                     #
############################################################

# md5sum for each file of each archive 

find_duplicates