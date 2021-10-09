#!/bin/bash
cd $HOST_DIR
HOST_UID=$(stat -c '%u' ./)
getent passwd $HOST_UID
if [ $? -ne 0 ]
then
  useradd $HOST_USERNAME -u $HOST_UID -m  2>/dev/null
  chown $HOST_USERNAME:$HOST_USERNAME /home/$HOST_USERNAME
fi
if [ $# -eq 0 ]
then
  set -- "/bin/bash" "$@"
fi
sudo -u \#$HOST_UID env \
  PATH="$PATH" \
  PYTHONPATH="$PYTHONPATH" \
  WATERSHED_WORKFLOW_DIR="$WATERSHED_WORKFLOW_DIR" \
  SEACAS_DIR="$SEACAS_DIR" \
  $@
