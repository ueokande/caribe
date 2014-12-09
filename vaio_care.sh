on_off() {
  if [ $# -lt 2 ]; then
    echo 'off'
  elif [ $1 = $2 ]; then
    echo 'on'
  else
    echo 'off'
  fi
}

battery_care() {
  file='/sys/devices/platform/sony-laptop/battery_care_limiter'
  current_value=$(<$file)
  dialog --radiolist 'Set the fan contolls' \
                     0 60 0 \
                     '50' 'Battery care (50%)' `on_off 50 "$current_value"`\
                     '80' 'Battery care (80%)' `on_off 80 "$current_value"`\
                     '100' 'Disable battery care' `on_off 100 "$current_value"`\
         2>$tmp
  if [ $? == 0 ]; then
    echo `cat $tmp` >$file || exit 1
  fi
}

fan_controll() {
  file='/sys/devices/platform/sony-laptop/thermal_control'
  current_value=$(<$file)
  dialog --radiolist 'Set the fan contolls' \
                     0 60 0 \
                     'balanced' 'Balanced performance mode' `on_off balanced "$current_value"`\
                     'silent' 'Silent fan mode' `on_off silent "$current_value"`\
                     'performance' 'High performance mode' `on_off performance "$current_value"`\
         2>$tmp
  if [ $? == 0 ]; then
    echo `cat $tmp` >$file || exit 1
  fi
}

kbd_backlight() {
  file='/sys/devices/platform/sony-laptop/kbd_backlight'
  current_value=$(<$file)
  dialog --radiolist 'Enable/disable the keyboard backlight' \
                     0 60 0 \
                     '0' 'Disable' `on_off 0 "$current_value"`\
                     '1' 'Enable' `on_off 1 "$current_value"`\
         2>$tmp
  if [ $? == 0 ]; then
    echo `cat $tmp` >$file || exit 1
  fi
}

mainmenu() {
  battery_care='Battery Care'
  fan_controll='Fan Controll'
  kbd_backlight='Keyboard Backlight'
  while true; do
    dialog --title 'VAIO Care' \
           --menu 'Select an item to configure' 0 60 0 \
                  "$battery_care" 'Set the maximum of the battery charge' \
                  "$fan_controll" 'Set the fan controlls' \
                  "$kbd_backlight" 'Enable/disable the keyboard backlight' \
           2>$tmp
    if [ "$?" != "0" ]; then return; fi

    choice=$(< $tmp)
    case $choice in
      "$battery_care") battery_care;;
      "$fan_controll") fan_controll;;
      "$kbd_backlight") kbd_backlight;;
    esac
  done
}

tmp=`mktemp`
trap "rm $tmp" EXIT

mainmenu
clear
