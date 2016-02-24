#!/bin/bash

function main() {
    echo "This script has the potential to break things! Only continue\n after you are 100% sure that you know which drive you are wiping!"
    echo "What device would you like to secure erase?"
    read dev

    spass="erasure"

    supported=$(sudo hdparm -I $dev | grep -iq 'supported: enhanced erase')
    if [ $? -ne 0 ]; then
      echo "Device does not support secure erase, sorry!"
      exit
    fi

    frozen=$(sudo hdparm -I $dev | grep -i 'frozen' | grep -iq 'not')
    if [ $? -ne 0 ]; then
      echo "Device is frozen, please suspend your computer and wake it back up."
      exit
    fi

    frozen=$(sudo hdparm -I $dev | grep -i 'locked' | grep -iq 'not')
    if [ $? -ne 0 ]; then
      echo "Device is locked, what is the password?"
      read spass
    fi

    echo "Device has passed my tests, I'm going to erase it now."
    echo "Waiting for 5 seconds to ensure you've said your final goodbyes to your data..."
    sleep 5

    echo "Setting user password"
    hdparm --user-master u --security-set-pass $spass $dev
    echo "Erasing"
    time hdparm --user-master u --security-erase $spass $dev

    if [ $? -ne 0 ]; then
      echo "I broke for some reason... Maybe you should scroll up and fix me!"
      exit
    fi

    echo "Your device should now be void of any data, congratulations!"
}

if [ "$(whoami)" == "root" ]; then
  main
else
  echo "Running as root"
  sudo $0
fi
