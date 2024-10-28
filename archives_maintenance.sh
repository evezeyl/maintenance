#!/bin/bash
# script to help maintenance of files in archives
#  model https://github.com/NorwegianVeterinaryInstitute/Diverse_ISAV/blob/main/scripts/DEL_HPR/extract_reads.sh 
# /run/media/evezeyl/Elements/GITS/maintenance/archives_maintenance.sh 


############################################################
#                         Help                             #
############################################################
# https://www.redhat.com/sysadmin/arguments-options-bash-scripts
Help() {
   # Display Help
   echo "Facilitates maintainance of archives .tar.gz files"
   echo
   echo "Syntax: archives_maintenance.sh -[d|h]"
   echo "options:"
   echo "d     directory"
   echo "c     command to execute: 'content' to list content archives, 'decompress' to decompress archives"
   echo "      'both' do both (default: content)"
   echo "h     Print this Help."
   echo
}
# setting variables
mydirectory="mydirectory"
command="content"

# Getting options
while getopts "d:c:h" option
  do
   case $option in
     d) # mydirectory
     mydirectory=$OPTARG;;
     c) # command to execute
     command=$OPTARG;;
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

list_archives_content() {
  # create a file with the prefix name of each archive and
  # list the contents of the archive in the file 
  for archive in $(ls ${mydirectory}/*.tar.gz)
  do
    archive_name=$(basename ${archive} | sed -e "s#.tar.gz##g") 
    mkdir -p ${mydirectory}/archives_content
    tar -tvf "$archive" > "${mydirectory}/archives_content/${archive_name}_content.txt"
  done
}


decompress_archives() {
  # decompress all archives in the directory
  for archive in $(ls ${mydirectory}/*.tar.gz)
  do
    tar -xvf "$archive" -C ${mydirectory}
    rm "$archive" 
  done
}


############################################################
#                       Running script                     #
############################################################

# md5sum for each file of each archive 
if [ "$command" == "content" -o "$command" == "both" ]; then
  list_archives_content 
fi 

if [ "$command" == "decompress" -o "$command" == "both" ]; then
  decompress_archives
fi




