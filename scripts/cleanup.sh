#clean up the contents of a directory
cleanup_directory_content() {
  if [ -d "$1" ]; then
    rm -rf "$1"/*
    echo "Removed content of $1"
  fi
}

# clean the contents of a directory by excluding a specific file
cleanup_directory_content_except() {
  if [ -d "$1" ]; then
    find "$1" -mindepth 1 -not -name "$2" -exec rm -rf {} +
    echo "Removed content of $1, except $2"
  fi
}

# Verify the arguments proposed
if [ $# -eq 0 ]; then
  
  cleanup_directory_content_except "data" "urls"
  cleanup_directory_content "res"
  cleanup_directory_content "out"
  cleanup_directory_content "log"
else

  for arg in "$@"; do
    case $arg in
      "data" | "res" | "out" | "log")
        if [ "$arg" == "data" ]; then
          cleanup_directory_content_except $arg "urls"
        else
          cleanup_directory_content $arg
        fi
        ;;
      *)
        echo "Invalid argument: $arg"
        ;;
    esac
  done
fi



