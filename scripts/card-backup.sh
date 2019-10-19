#!/usr/bin/env bash

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# IMPORTANT:
# Run the install-little-backup-box.sh script first
# to install the required packages and configure the system.


if [ -f /home/pi/lib_oled96/logo.py ]; then
    /home/pi/lib_oled96/logo.py

    sleep 3
fi

CONFIG_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
CONFIG="${CONFIG_DIR}/config.cfg"

source "$CONFIG"

if [ $LED = true ]; then
  ${CONFIG_DIR}/led.py ${LED_STARTUP}
fi

# Set the ACT LED to heartbeat
sudo sh -c "echo heartbeat > /sys/class/leds/led0/trigger"

# Shutdown after a specified period of time (in minutes) if no device is connected.
sudo shutdown -h $SHUTD "Shutdown is activated. To cancel: sudo shutdown -c"
END=`date --date="+$SHUTD minutes" +"%s"`
#sudo shutdown -c

# Wait for a USB storage device (e.g., a USB flash drive)
STORAGE=$(ls /dev/* | grep "$STORAGE_DEV" | cut -d"/" -f3)
if [ $DISP = true ]; then
    oled r
    oled +a "Shutdown active"
    oled +c "Insert storage"
fi

while [ -z "${STORAGE}" ]
do
    if [ $DISP = true ]; then
        NOW=`date +%s`
        DIFFSEC=`expr ${END} - ${NOW}`

        oled +b "in `date +%-M -ud @${DIFFSEC}`min `date +%-S -ud @${DIFFSEC}`s"
        sudo oled s
    fi

    sleep 1
    STORAGE=$(ls /dev/* | grep "$STORAGE_DEV" | cut -d"/" -f3)
done
# When the USB storage device is detected, mount it
mount /dev/"$STORAGE_DEV" "$STORAGE_MOUNT_POINT"

# Set the ACT LED to blink at 1000ms to indicate that the storage device has been mounted
sudo sh -c "echo timer > /sys/class/leds/led0/trigger"
sudo sh -c "echo 1000 > /sys/class/leds/led0/delay_on"

# If display support is enabled, notify that the storage device has been mounted
if [ $DISP = true ]; then
    oled r
    oled +a "Storage OK"
    oled +b "Card reader..."
    sudo oled s
fi

if [ $LED = true ]; then
  ${CONFIG_DIR}/led.py ${LED_STORAGE_MOUNTED}
fi

# Wait for a card reader or a camera
# takes first device found
CARD_READER=($(ls /dev/* | grep "$CARD_DEV" | cut -d"/" -f3))
until [ ! -z "${CARD_READER[0]}" ]
  do
  sleep 1
  CARD_READER=($(ls /dev/* | grep "$CARD_DEV" | cut -d"/" -f3))
done

# If the card reader is detected, mount it and obtain its UUID
if [ ! -z "${CARD_READER[0]}" ]; then
  mount /dev"/${CARD_READER[0]}" "$CARD_MOUNT_POINT"

  # Set the ACT LED to blink at 500ms to indicate that the card has been mounted
  sudo sh -c "echo 500 > /sys/class/leds/led0/delay_on"
  if [ $LED = true ]; then
    ${CONFIG_DIR}/blink.py ${LED_COPYING} &
  fi

  # Cancel shutdown
  sudo shutdown -c

  # If display support is enabled, notify that the card has been mounted
  if [ $DISP = true ]; then
      oled r
      oled +a "Card reader OK"
      oled +b "Working..."
      sudo oled s
  fi

  # Create  a .id random identifier file if doesn't exist
  cd "$CARD_MOUNT_POINT"
  if [ ! -f *.id ]; then
    random=$(echo $RANDOM)
    touch $(date -d "today" +"%Y%m%d%H%M")-$random.id
  fi
  ID_FILE=$(ls *.id)
  ID="${ID_FILE%.*}"
  cd

  # Set the backup path
  BACKUP_PATH="$STORAGE_MOUNT_POINT"/"$ID"
  # Perform backup using rsync
  rsync -avh --info=progress2 --exclude "*.id" "$CARD_MOUNT_POINT"/ "$BACKUP_PATH"
fi

# If display support is enabled, notify that the backup is complete
if [ $DISP = true ]; then
    oled r
    oled +a "Backup complete"
    sudo oled s

    # If display support is enabled, display storage space info
    storsize=$(df /dev/"$STORAGE_DEV"  -h --output=size | sed '1d')
    storused=$(df /dev/"$STORAGE_DEV"  -h --output=pcent | sed '1d')
    storfree=$(df /dev/"$STORAGE_DEV"  -h --output=avail | sed '1d')
    oled r
    oled +a "Avail. storage"
    oled +b "Total: $storsize"
    oled +c " Used: $storused"
    oled +d " Free: $storfree"
    sudo oled s

    sleep 3

    oled r
    oled +a "Shutting down"
    sudo oled s
    sleep 2
fi




if [ $LED = true ]; then
  sudo pkill -f blink.py
  ${CONFIG_DIR}/led.py ${LED_DONE}
fi

# Shutdown
sync
if [ $DISP = true ]; then
    oled r
fi

shutdown -h now

if [ $DISP = true ]; then
  oled r
  sudo oled s
fi
