#!/bin/bash

############### CONFIG ##################

BASE_DIR=
APP_FILENAME=
SYSD_SERVICE_PREFIX=

############### GLOBALS #################

ABS_APP_FILENAME=${BASE_DIR}$APP_FILENAME

############### FUNCTIONS ###############

function deleteOldBackup() {
  # $1 -> umgebung
  echo "--- Delete Backup-File '$1'"
  ABS_BACKUP_FILE=${BASE_DIR}$1/${APP_FILENAME}.old
  if test -f "$ABS_BACKUP_FILE"
  then
    echo "------ File existiert -> Delete '$ABS_BACKUP_FILE'"
    rm $ABS_BACKUP_FILE
  fi
}

function createNewBackup() {
  # $1 -> umgebung
  echo "--- Erzeuge Backup-File '$1'"
  ABS_CURR_APP_FILE=${BASE_DIR}$1/$APP_FILENAME
  ABS_BACKUP_FILE=${ABS_CURR_APP_FILE}.old
  echo "------ Kopiere [$ABS_CURR_APP_FILE] -> [$ABS_BACKUP_FILE]"
  cp $ABS_CURR_APP_FILE $ABS_BACKUP_FILE
}

function stopAppService() {
  # $1 -> umgebung
  echo "--- Stoppe App-Service '$1'"
  echo "------ Stoppe Service [${SYSD_SERVICE_PREFIX}-${1}]"
  systemctl stop ${SYSD_SERVICE_PREFIX}-${1}
}

function copyAppFile() {
  # $1 -> umgebung
  echo "--- Kopiere Application-File '$1'"
  ABS_APP_NEU_FILE=${BASE_DIR}$1/$APP_FILENAME
  echo "------ Kopiere [$ABS_APP_FILENAME] -> [$ABS_APP_NEU_FILE]"
  cp $ABS_APP_FILENAME $ABS_APP_NEU_FILE
}

function startAppService() {
  # $1 -> umgebung
  echo "--- Starte App-Service '$1'"
  echo "------ Starte Service [${SYSD_SERVICE_PREFIX}-$1]"
  systemctl start ${SYSD_SERVICE_PREFIX}-$1
}

function swap() {
  # $1 -> umgebung
  echo -e "\n================= START: '$1' ==================\n"
  deleteOldBackup $1
  echo -e "\n"
  createNewBackup $1
  echo -e "\n"
  stopAppService $1
  echo -e "\n"
  copyAppFile $1
  echo -e "\n"
  startAppService $1
  echo -e "\n================= ENDE: '$1' ==================\n"
}

############### MAIN ###############

# Beim Aufruf des Scripts muss mindestens ein Argument angegeben werden.
if test "$#" -lt 1
then
  echo "ERROR: Dem Script muss mindestens 1 Argument uebergeben worden sein!"
  echo "USAGE: $0 [dev test int]; z.B. '$0 test' oder '$0 dev test int'"
  exit 1
fi

# JAR muss an richtiger Stelle liegen.
echo -e "\n\n--- Precheck: Existiert File [$ABS_APP_FILENAME]?"

if test -f "$ABS_APP_FILENAME"
then
  echo "------ File existiert -> Precheck OK"
else
  echo "------ ERROR: File '$ABS_APP_FILENAME' existiert nicht."
  exit 1
fi

# DEV
for X in "$@"
do
  if test "$X" = "dev"
  then
    # OK -> Lets swap the "dev"-application.
    swap "dev"
    break
  fi
done
# TEST
for X in "$@"
do
  if test "$X" = "test"
  then
    # OK -> Lets swap the "test"-application.
    swap "test"
    break
  fi
done
# INT
for X in "$@"
do
  if test "$X" = "int"
  then
    # OK -> Lets swap the "int"-application.
    swap "int"
    break
  fi
done

