#!/bin/bash
############################################################
#                       usage functions                    #
############################################################

# Defines usage functions
function usage() {
  # Usage help for script and main options implemented as functions
  echo "Usage: $0 [OPTIONS] COMMAND"
  echo ""
  echo "Options:"
  echo "  -h, --help          Show this help message and exit"
  echo ""
  echo "Commands:"
  echo "  remove-spaces       Remove spaces from filenames, option replace those names in sh, txt, md files in given directory"
  echo "  sync-directories    Synchronize two directories"
  #echo "  find_dup            detect duplicates"
  #echo "  remove_dup	      remove duplicates"
  echo ""
  echo "note: ignore files in hidden directories" 
  echo "Run '$0 COMMAND --help' for more information on a command."
}

function remove_spaces_usage() {
  # Usage help for function remove_spaces
  echo "Remove spaces from filenames, option replace those names in sh, txt, md files in given directory"
  echo "Usage: $0 remove-spaces [OPTIONS] DIRECTORY OPTION2"
  echo ""


  echo "Options:"
  echo "  -h, --help                        Show this help message and exit"
  echo ""

  echo "Positional arguments:"
  echo "  DIRECTORY                         Directory that will be scanned for files that have names with spaces that 
                                            will be renamed"
  echo "  OPTION2                           Either update references to those files within txt, sh and md files in the given
                                            'UPDATE_DIRECTORY' OR desactivates this function whith '--no-scan' "
  }

function sync_directories_usage() {
  # Usage help for function sync_directories
  echo "Usage: $0 sync-directories  [OPTIONS]  SOURCE_DIRECTORY DESTINATION_DIRECTORY"
  echo ""
  
  echo "Options:              Corresponds to: rsync -av --delete SOURCE_DIRECTORY DESTINATION_DIRECTORY"
  echo "  -h, --help          Show this help message and exit"
  echo ""
  
  echo "Positional arguments:"
  echo "SOURCE_DIRECTORY        Directory with original files" 
  echo "DESTINATION_DIRECTORY  Directory for backing up files"
}

############################################################
#     Functions definition for each option                 #
############################################################

# remove spaces within filenames and rename with underscores
# optionally scan txt, md, sh files in a specific directory and replace old names with new names 

function remove_spaces() {
  scan_references=true

  # help if requested help
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        remove_spaces_usage
        return 0
        ;;
      *)
        break
        ;;
    esac       
  done

  # help if not 2 argments
  if [[ $# -ne 2 ]]; then
    remove_spaces_usage
    return 1
  fi


  dir_path="$1"
  update_dir_path="$2"


  # Disable scan option - Should be done better
  if [ "$update_dir_path" == "--no-scan" ]; then 
    scan_references=false
  fi 

  # array files: files with space names in dir_path 
  #mapfile -d $'\0' files < <(find "$dir_path" -type f -name "* *" -print0)
  ## ignore hidden 
  mapfile -d $'\0' files < <(find "$dir_path" -name '.*' -prune -o -type f -name "* *" -print0)


  # array new_files :  spaces replaced by underscores 
  for ((i=0; i<${#files[@]}; i++)); do
    new_files[i]=${files[i]// /_}
  done

  # Rename files with spaces in their names
  for ((i=0; i<${#files[@]}; i++)); do
    mv "${files[i]}" "${new_files[i]}"
    #echo "${files[i]}" + "&&" + "${new_files[i]}"
  done

  # rename within sh, md and txt files 
  if [[ "$scan_references" = true ]]; then
    # Find all files in the update directory with the extensions you want
    # mapfile -d $'\0' update_files < <(find "$update_dir_path" -type f \( -name "*.txt" -o -name "*.sh" -o -name "*.md" \) -print0)
    mapfile -d $'\0' update_files < <(find "$update_dir_path" -name '.*' -prune -o -type f \( -name "*.txt" -o -name "*.sh" -o -name "*.md" \) -print0)

    # Iterates over all the update files and replace the references to files with spaces
    for ((i=0; i<${#update_files[@]}; i++)); do
      for ((j=0; j<${#files[@]}; j++)); do
        old_name="${files[j]}"
        new_name="${new_files[j]}"
        sed -i "s|$old_name|$new_name|g" "${update_files[i]}"
      done
    done

  fi
  
}

# Synchronize directories using rsync
function sync_directories() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        sync_directories_usage
        return 0
        ;;
      *)
        break
        ;;
    esac
  done

  if [[ $# -ne 2 ]]; then
    sync_directories_usage
    return 1
  fi

  source_dir="$1"
  dest_dir="$2"

  # running synchronisation with rsync
  rsync -av --delete "$source_dir" "$dest_dir"

}

############################################################
#                       Script launching                   #
############################################################
# no arguments: launch help
if [[ $# -eq 0 ]]; then
  usage
  exit 1
# several arguments - launch function. Each function has its own help if not launched correctly
else
  case "$1" in 
    "remove-spaces")
      # launches remove-spaces with remainder args
      remove_spaces "${@:2}"
      exit 0
      ;;
    "sync-directories")
      # launches syncing-directories with remainder args
      sync_directories "${@:2}"
      exit 0
      ;;
    *)
      echo "Error: Unrecognized command '$1'."
      usage
      exit 1
      ;;
  esac

fi

