#!/bin/bash

############### CONFIG ##################
# Dir indem dieses Script als auch der APP-File(JAR) liegt. (Vorsicht: muss mit '/' enden)
BASE_DIR=/vagrant/pss/
# Kompletter Filename
APP_FILENAME=pss-2021.4.0-SNAPSHOT.jar
# Z.B. systemctl status portale-sync-dev
SYSD_SERVICE_PREFIX=portale-sync


############### GLOBALS #################

ABS_APP_FILENAME=${BASE_DIR}$APP_FILENAME

############### FUNCTIONS ###############

function deleteOldBackup() {
  # $1 -> umgebung
  echo "--- Loesche Backup-File '$1' falls dieser existiert"
  ABS_BACKUP_FILE=${BASE_DIR}$1/${APP_FILENAME}.old
  if test -f "$ABS_BACKUP_FILE"
  then
    echo "------ File existiert -> Loesche '$ABS_BACKUP_FILE'"
    rm $ABS_BACKUP_FILE
  fi
}

function createNewBackup() {
  # $1 -> umgebung
  echo "--- Erzeuge neuen Backup-File '$1'"
  ABS_CURR_APP_FILE=${BASE_DIR}$1/$APP_FILENAME
  ABS_BACKUP_FILE=${ABS_CURR_APP_FILE}.old
  echo "------ Kopiere [$ABS_CURR_APP_FILE] -> [$ABS_BACKUP_FILE]"
  cp $ABS_CURR_APP_FILE $ABS_BACKUP_FILE
}

function stopAppService() {
  # $1 -> umgebung
  echo "--- Stoppe systemd-Service '$1'"
  echo "------ Stoppe Service [${SYSD_SERVICE_PREFIX}-${1}]"
  systemctl stop ${SYSD_SERVICE_PREFIX}-${1}
}

function copyAppFile() {
  # $1 -> umgebung
  echo "--- Kopiere JAR '$1'"
  ABS_APP_NEU_FILE=${BASE_DIR}$1/$APP_FILENAME
  echo "------ Kopiere [$ABS_APP_FILENAME] -> [$ABS_APP_NEU_FILE]"
  cp $ABS_APP_FILENAME $ABS_APP_NEU_FILE
}

function startAppService() {
  # $1 -> umgebung
  echo "--- Starte systemd-Service '$1'"
  echo "------ Starte Service [${SYSD_SERVICE_PREFIX}-$1]"
  systemctl start ${SYSD_SERVICE_PREFIX}-$1
}

function swap() {
  # $1 -> umgebung
  echo -e "\n================= START: '$1' =================="
  #deleteOldBackup $1
  #echo -e "\n"
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
  echo "ERROR: Dem Script muss mindestens 1 Argument uebergeben worden sein!" >&2
  echo "USAGE: $0 [dev test int]; z.B. '$0 test' oder '$0 dev test int'" >&2
  exit 1
fi

# JAR muss an richtiger Stelle liegen.
echo -e "\n\n--- Precheck: Existiert File [$ABS_APP_FILENAME]?"

if test -f "$ABS_APP_FILENAME"
then
  echo "------ File existiert -> Precheck OK; Beginne Austausch ..."
else
  echo "------ ERROR: File '$ABS_APP_FILENAME' existiert nicht." >&2
  exit 1
fi

for X in "$@"
do
  case $X in
    dev|test|int)
      swap $X
      ;;
    prod)
      echo "ERROR: PROD ist nicht supported!" >&2
      ;;
    *)
      echo "ERROR: Kein gueltiger Input; nur [dev test int] erlaubt!" >&2
  esac
done

echo "... Austausch fertig"
