#!/usr/bin/env zsh

# This function exists for a specialized (antique) liquibase process and is not applicable to most lb development
function lb() {
  # Go in the liquibase migration module
  cd "$LIQUIBASE_HOME"

  # capture arg
  ACTION="${1:-Help}"

  # if [[ -f "$LIQUIBASE_HOME/liquibase-config.sh"]]
  #  source "$LIQUIBASE_HOME"/liquibase-config.sh
  # else
  #   echo "No liquibase-config.sh file found in $PWD"
  #   exit -1
  # fi

  # #TODO: Case error
  # case "$ACTION" in 
  #   "update")
  #     echo "updating lb database"
  #     "$LIQUIBASE" --changeLogFile update.xml update 2>&1 | tee -a liquibase.log 
  #   ;;
  #   *)
  #     echo "Command $1 not recognized"
  #   ;;  
  # esac
}
