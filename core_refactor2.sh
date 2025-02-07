export gui=$1
clear -x
echo "These are here because I'm a lazy coder and i want an easy reference for text formatting in the menu - if you're able to read this inside the program, something is very wrong."
echo -e "\e[30mBlack Text\e[0m"
echo -e "\e[31mRed Text\e[0m"
echo -e "\e[32mGreen Text\e[0m"
echo -e "\e[33mBrown Text\e[0m"
echo -e "\e[34mBlue Text\e[0m"
echo -e "\e[35mPurple Text\e[0m"
echo -e "\e[36mCyan Text\e[0m"
echo -e "\e[37mLight Gray Text\e[0m"

echo -e "\e[1mbold\e[0m"
echo -e "\e[3mitalic\e[0m"
echo -e "\e[3m\e[1mbold italic\e[0m"
echo -e "\e[4munderline\e[0m"
echo -e "\e[9mstrikethrough\e[0m"
echo -e "\e[31mHello World\e[0m"
echo -e "\x1B[31mHello World\e[0m"
clear -x
x=1
megascript_start_time=$(date +%s)

#allow developer to set repository username and branch
#developers use export repository_username= and export repository_branch= for your own github username and branch of the L4T-Megascript
if [ -v $repository_username ] || [ $repository_username == cobalt2727 ]; then
  export repository_username=cobalt2727
else
  echo "Developer Mode Enabled! Repository = $repository_username"
fi
if [ -v $repository_branch ] || [ $repository_branch == master ]; then
  export repository_branch=master
else
  echo "Developer Mode Enabled! Branch = $repository_branch"
fi

function online_check {
    while : ; do
    clear -x
    date
    echo "Checking internet connectivity..."
    #silently check connection to github AND githubusercontent, we had an edge case where a guy was getting githubusercontent blocked by his ISP
    wget -q --spider https://github.com && wget -q --spider https://raw.githubusercontent.com/

    #read whether or not it was successful
    #the $? reads the exit code of the previous command, 0 meaning everything works
    if [ $? == 0 ]
    then
	echo -e "\e[32mInternet OK\e[0m"
        break
    fi
    #tell people to fix their internet
    echo "You're offline and/or can't reach GitHub."
    echo "We can't run the script without this..."
    echo "You'll need to connect to WiFi or allow GitHub in your firewall."
    echo "(you can close this window at any time.)"
    echo "Retrying the connection in..."
    ########## bootleg progress bar time ##########
    echo -e "\e[31m5\e[0m"
    printf '\a'
    sleep 1
    echo -e "\e[33m4\e[0m"
    printf '\a'
    sleep 1
    echo -e "\e[32m3\e[0m"
    printf '\a'
    sleep 1
    echo -e "\e[34m2\e[0m"
    printf '\a'
    sleep 1
    echo -e "\e[35m1\e[0m"
    printf '\a'
    echo "Trying again..."
    sleep 1
    #and now we let it loop
    done
}

function add_desktop {
  #create .desktop file for the megascript
  sudo rm -rf /tmp/L4T-Megascript.desktop
  sudo rm -rf /tmp/L4T-Megascript.png
  sudo wget "https://raw.githubusercontent.com/$repository_username/L4T-Megascript/$repository_branch/assets/L4T_Megascript-logo-transparent.png" -O /tmp/L4T-Megascript.png && sudo rm -rf /usr/share/icons/L4T-Megascript.png && sudo mv /tmp/L4T-Megascript.png /usr/share/icons/L4T-Megascript.png
  sudo wget "https://raw.githubusercontent.com/$repository_username/L4T-Megascript/$repository_branch/assets/L4T-Megascript.desktop" -O /tmp/L4T-Megascript.desktop && sudo rm -rf /usr/share/applications/L4T-Megascript.desktop && sudo mv /tmp/L4T-Megascript.desktop /usr/share/applications/L4T-Megascript.desktop
  sudo chmod 644 '/usr/share/applications/L4T-Megascript.desktop'
}
FUNC=$(declare -f add_desktop)

dependencies=("bash" "dialog" "gnutls-bin" "curl" "yad" "zenity")
## Install dependencies if necessary
dpkg -s "${dependencies[@]}" >/dev/null 2>&1 || if [[ $gui == "gui" ]]; then
  pkexec sh -c "apt update; apt upgrade -y; apt-get install $(echo "${dependencies[@]}") -y; hash -r; $FUNC; repository_branch=$repository_branch; repository_username=$repository_username; add_desktop; hash -r"
else
  sudo sh -c "apt update; apt upgrade -y; apt-get install $(echo "${dependencies[@]}") -y; hash -r; $FUNC; repository_branch=$repository_branch; repository_username=$repository_username; add_desktop; hash -r"
fi

function install_post_depends {
  ## Check SDL2 version
  if $(dpkg --compare-versions $(dpkg-query -f='${Version}' --show libsdl2-2.0-0) lt 2.0.14); then
    echo "Installing SDL2 from binary..."
    bash -c "$(curl -s https://raw.githubusercontent.com/$repository_username/L4T-Megascript/$repository_branch/scripts/sdl2_install_helper.sh)"
  fi
}

function add_desktop_if {
  test -f "/usr/share/applications/L4T-Megascript.desktop" || if [[ $gui == "gui" ]]; then
    zenity --info --width="500" --height="250" --title "Welcome!" --text "Looks like you don't have the L4T-Megascript.desktop file (the applications icon) \nPlease give your password at the prompt"
    pkexec sh -c "$FUNC; repository_branch=$repository_branch; repository_username=$repository_username; add_desktop; hash -r"
    clear -x
  else
    echo 'Looks like you do not have the L4T-Megascript.desktop file (the applications icon)'
    echo "Please give your password at the prompt"
    sudo sh -c "$FUNC; repository_branch=$repository_branch; repository_username=$repository_username; add_desktop; hash -r"
    clear -x
  fi
}

function error_fatal {
  echo -e "\\e[91m$1\\e[39m"
  sleep 10
  exit 1
}

#load functions from github source
unset functions_downloaded
source <(curl -s https://raw.githubusercontent.com/$repository_username/L4T-Megascript/$repository_branch/functions.sh)
[[ ! -z ${functions_downloaded+z} ]] && status "Functions Loaded" || error_fatal "Oh no! Something happened to your internet connection! Exiting the Megascript - please fix your internet and try again!"

conversion() {
  for ((i = 1; i <= ${length}; i++)); do
    if [[ ! " ${hidden[@]} " =~ " ${i} " ]]; then
      fn=""
      d=""
      e=""
      f=""
      sn=""
      selected="FALSE"
      is_root=""
      line=$(echo "$apps" | sed -n $i"p")
      if [[ "$line" != \#* ]]; then
        eval "$(echo "$line" | tr ";" "\n")"
        scripts[$i]=$sn
        friendly[$i]=$fn
        if [ "$f" = "scripts" ]; then
          folder[$i]=$f
        else
          folder[$i]="scripts/$f"
        fi
        execute[$i]=$e
        root[$i]=$is_root
        if [[ $gui == "gui" ]]; then
          ids+=($f)
          declare -n current_table=table_$f
          f="$(echo "$f" | sed -e 's/_/ /g' | sed -e "s/\b\(.\)/\u\1/g")"
          current_table+=($selected $i "$fn" "$d")
          unset -n current_table
          table_all_categories+=($selected $i "$f" "$fn" "$d")
        else
          ff="$(echo "$f" | sed -e 's/_/ /g' | sed -e "s/\b\(.\)/\u\1/g")"
          echo "$i...............$ff - $fn - $d"
        fi
      fi
    fi
  done
}
# force reload programs list
hash -r
hidden=()

apps=$(wget -qO- https://raw.githubusercontent.com/$repository_username/L4T-Megascript/$repository_branch/megascript_apps.txt)
apps=$(echo "$apps" | sed '/^$/d')
length=$(echo "$apps" | wc -l | awk '{ print $1 }')

if [[ "$apps" == "" ]]; then
  description="...Uh oh. We couldn't download the app list!\
\nPlease make sure you are still connected to the internet.\
\n\nIf you need help, copy the log and create a GitHub issue or ask for help on our Discord!"
  table=("Exit")
  userinput_func "$description" "${table[@]}"
  exit
fi

# get switchroot version
if [ -f /etc/switchroot_version.conf ]; then
  clear -x
  swr_ver=$(cat /etc/switchroot_version.conf)
  swr_ver_current="3.4.0"
  function version { echo "$@" | awk -F. '{ printf("%d%03d%03d%03d%03d\n", $1,$2,$3,$4,$5); }'; }
  if [ $(version $swr_ver) -lt $(version $swr_ver_current) ]; then
    if [[ $gui == "gui" ]]; then
      yad --center --image "dialog-warning" --width="500" --height="250" --title "Welcome!" --text "Your L4T Ubuntu version is out of date! You have L4T $swr_ver and the currrent version is $swr_ver_current! \
      \n\n\Please update as soon as you can.\nThe instructions are at the 'Downloads' section of https://wiki.switchroot.org/en/Linux/Ubuntu-Install-Guide. \
      \n\nA web browser will launch with the instructions after you hit OK! " --window-icon=/usr/share/icons/L4T-Megascript.png
      setsid x-www-browser "https://wiki.switchroot.org/en/Linux/Ubuntu-Install-Guide" > /dev/null 2>&1 &
    else
      echo "You L4T Ubuntu version is out of date! You have L4T $swr_ver and the currrent version is $swr_ver_current!"
      echo "Please update as soon as you can."
      echo "The instructions are at the 'Downloads' section of https://wiki.switchroot.org/en/Linux/Ubuntu-Install-Guide."
      echo ""
      read  -n 1 -p "Press any key to continue" mainmenuinput
    fi
  fi
fi

#remove week-old logfiles
mkdir -p ~/L4T-Megascript/logs
find "~/L4T-Megascript/logs" -type f -mtime +7 -exec rm -f {} \; &>/dev/null &

while [ $x == 1 ]; do
  cd ~
  available_space=$(df -PH . | awk 'NR==2 {print $4"B"}')
  clear -x
  table=()
  scripts=()
  friendly=()
  folder=()
  execute=()
  ids=()
  if [[ $gui == "gui" ]]; then
    yad --center --image "dialog-information" --width="500" --height="250" --borders="20" --fixed --title "Welcome!" --text "Welcome back to the main menu of the L4T Megascript, $USER!\n\nAdd a check from the choices in the GUI and then press INSTALL to configure the specified program.\nDISCLAIMER: We will *anonymously* collect and upload log files from your device to our Discord server any time a script fails.\nRun the initial setup script if this is your first time!" --window-icon=/usr/share/icons/L4T-Megascript.png --button=Ok:0
    yad --center --image "dialog-information" --width="500" --height="250" --borders="20" --fixed --title "Welcome!" --text "You have $available_space of space left on your SD card! Make sure you don't use too much! \
    \n\n\Device Info:\n\nKernel Architecture: $architecture\nUserspace Architecture: $dpkg_architecture\nModel Name: $jetson_model $model" --window-icon=/usr/share/icons/L4T-Megascript.png --button=Ok:0
    free=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)
    divisor="1024000"
    free_gb=$(echo "scale=2 ; $free / $divisor" | bc)
    if [[ $free -lt 2048000 ]]; then
      yad --center --warning --width="500" --height="250" --title "Welcome!" --text "You have only $free_gb GB of free ram! \
      \n\n\Please consider closing out of any unnecessary programs before starting the Megascript." --window-icon=/usr/share/icons/L4T-Megascript.png
    fi
    add_desktop_if
    conversion
    uniq_selection=()
    CHOICE=""
    uniq=($(printf "%s\n" "${ids[@]}" | sort -u))
    for string in "${uniq[@]}"; do
      pretty_string="$(echo "$string" | sed -e 's/_/ /g' | sed -e "s/\b\(.\)/\u\1/g")"
      uniq_selection+=(FALSE " $pretty_string" "$string")
    done
    uniq_selection+=(TRUE "All Categories" "all_categories")
    while [ "$CHOICE" == "Go back to categories" -o "$CHOICE" == "" ]; do
      CATEGORY=$(
        yad --center \
          --width="250" \
          --height="350" \
          --title "Welcome to the L4T Megascript" \
          --text "Please choose a scripts category" \
          --borders="20" \
          --window-icon=/usr/share/icons/L4T-Megascript.png \
          --list \
          --radiolist \
          --separator='' \
          --column "Selection" \
          --column "Category" \
          --column "Real Folder" \
          --hide-column=3 \
          --print-column=3 \
          "${uniq_selection[@]}" \
          --button="Exit the Megascript":1 \
          --button="Go to selection":0
      )
      if [ "$?" != 1 ]; then
        category_space="$(echo "$CATEGORY" | sed -e 's/_/ /g' | sed -e "s/\b\(.\)/\u\1/g")"
        declare -n current_table="table_$CATEGORY"
        if [ "$CATEGORY" == "all_categories" ]; then
          CHOICE=$(
            yad --center \
              --width="1000" \
              --height="500" \
              --title "$category_space" \
              --text "Please select the desired Programs to install" \
              --borders="20" \
              --window-icon=/usr/share/icons/L4T-Megascript.png \
              --list \
              --checklist \
              --column "Install" \
              --column "Number" \
              --column "Category" \
              --column "Program" \
              --column "Details" \
              --ok-label="INSTALL" \
              --hide-column=2 \
              --print-column=2 \
              "${current_table[@]}" \
              --separator=':' \
              --button="Exit the Megascript":1 \
              --button="Install items":0 \
              --button="Go back to categories":2
          )
        else
          CHOICE=$(
            yad --center \
              --width="1000" \
              --height="500" \
              --title "$category_space" \
              --text "Please select the desired programs to install" \
              --borders="20" \
              --window-icon=/usr/share/icons/L4T-Megascript.png \
              --list \
              --checklist \
              --column "Install" \
              --column "Number" \
              --column "Program" \
              --column "Details" \
              --ok-label="INSTALL" \
              --hide-column=2 \
              --print-column=2 \
              "${current_table[@]}" \
              --separator=':' \
              --button="Exit the Megascript":1 \
              --button="Install Items":0 \
              --button="Go Back to Categories":2
          )
        fi
        output="$?"
        if [[ "$output" == "0" ]]; then
          sudo -k
          state="0"
          while [[ "$state" == "0" ]]; do
            zenity --password | sudo -S echo "" 2>&1 >/dev/null | grep -q "incorrect"
            state=$?
          done
          add_english
        elif [[ "$output" == "2" ]]; then
          CHOICE="Go Back to Categories"
        else
          CHOICE="exit"
        fi
        unset -n current_table
      else
        CHOICE="exit"
      fi
    done
    x=0
  else
    free=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)
    divisor="1024000"
    free_gb=$(echo "scale=2 ; $free / $divisor" | bc)
    if [[ $free -lt 2048000 ]]; then
      echo "You have only $free_gb GB of free ram!"
      echo "Please consider closing out of any unnecessary programs before starting the megascript."
      sleep 4
    fi
    echo "Welcome back to the main menu of the L4T Megascript, $USER. This isn't quite finished yet - we'll be ready eventually!"
    echo
    add_desktop_if
    echo -e "\x1B[31mYou have about $available_space of space left on your Linux installation! Make sure you don't use too much!\e[0m"
    echo "You are running an $architecture $jetson_model $model system."
    echo ""
    echo "Enter a number from the choices below and then press ENTER to configure the specified program."
    echo -e "\e[31mDISCLAIMER: We will *anonymously* collect and upload log files from your device to our Discord server any time a script fails.\e[0m"

    sleep 2
    echo
    conversion
    echo "X...............Close L4T Megascript, view credits and source code, and get Discord support server link"
    echo
    echo
    read -p "Make a selection: " CHOICE
    if [[ $CHOICE == x || $CHOICE == X || $CHOICE == exit || $CHOICE == Exit ]]; then
      x=0
      continue
    else
      sudo -S echo ""
      add_english
    fi

    echo "you have chosen $CHOICE"

  fi
  # https://unix.stackexchange.com/questions/261103/how-do-i-maintain-sudo-in-a-bash-script
  # initialize sudo password and extent timeout so we never run out
  IFS=":"
  if sudo -n true; then
    while true; do
      sleep 60
      sudo -v
      kill -0 "$$" 2>/dev/null || exit
    done &
    sudo apt update
    if [[ $? -ne 0 ]]; then
      # fix for error (for some reason was never pulled into bionic...)
      # http://launchpadlibrarian.net/384348932/appstream_0.12.2-1_0.12.2-2.diff.gz patch is seen at the bottom here
      # E: Problem executing scripts APT::Update::Post-Invoke-Success 'if /usr/bin/test -w /var/cache/app-info -a -e /usr/bin/appstreamcli; then appstreamcli refresh > /dev/null; fi'
      # https://askubuntu.com/questions/942895/e-problem-executing-scripts-aptupdatepost-invoke-success
      sudo sed -i 's%/dev/null;%/dev/null \| true;%g' /etc/apt/apt.conf.d/50appstream
      sudo apt update
    fi
    install_post_depends
    rm -rf /tmp/megascript_times.txt
    for word in $CHOICE; do
      #shamelessly take (and adapt) from Pi-Apps https://github.com/Botspot/pi-apps/blob/20378324ce92ca1e7634db77adc747a18ab214b2/manage#L221
      #determine path for log file to be created
      logfile="$HOME/L4T-Megascript/logs/install-incomplete-${friendly[$word]}.log"
      if [ -f "$logfile" ] || [ -f "$(echo "$logfile" | sed 's+-incomplete-+-success-+g')" ] || [ -f "$(echo "$logfile" | sed 's+-incomplete-+-fail-+g')" ];then
        #append a number to logfile's file-extension if the original filename already exists
        i=1
        while true;do
          #if variable $i is 2, then example newlogfile value: /path/to/install-Discord.log2
          newlogfile="$logfile$i"
          if [ ! -f "$newlogfile" ] && [ ! -f "$(echo "$newlogfile" | sed 's+/-incomplete-+-success-+g')" ] && [ ! -f "$(echo "$newlogfile" | sed 's+-incomplete-+-fail-+g')" ];then
            logfile="${newlogfile}"
            break
          fi
          i=$((i+1))
        done
        unset i
      fi

      time_script_start=$(date +%s)
      if [ -z ${execute[$word]} ]; then
        if [ -z ${root[$word]} ]; then
          bash -c "$(curl -s https://raw.githubusercontent.com/$repository_username/L4T-Megascript/$repository_branch/${folder[$word]}/${scripts[$word]} || echo 'error "Your internet seems to have died.... we could not download the script"')" &> >(tee -a "$logfile")
          script_exit_code="$?"
        else
          sudo -E bash -c "$(curl -s https://raw.githubusercontent.com/$repository_username/L4T-Megascript/$repository_branch/${folder[$word]}/${scripts[$word]} || echo 'error "Your internet seems to have died.... we could not download the script"')" &> >(tee -a "$logfile")
          script_exit_code="$?"
        fi

        if [ "$script_exit_code" != 0 ]; then
          echo -e  "\n\e[91mFailed to install ${friendly[$word]}!\e[39m
\e[40m\e[93m\e[5m🔺\e[25m\e[39m\e[49m\e[93mNeed help? Copy the \e[1mENTIRE\e[0m\e[49m\e[93m terminal output or take a screenshot.
Please ask on GitHub: \e[94m\e[4mhttps://github.com/cobalt2727/L4T-Megascript/issues\e[24m\e[93m
Or on Discord: \e[94m\e[4mhttps://discord.gg/abgW2AG87Z\e[0m" | tee -a "$logfile"
          # format_logfile "$logfile" #remove escape sequences from logfile
          mv "$logfile" "$(echo "$logfile" | sed 's+-incomplete-+-fail-+g')"
          logfile="$(echo "$logfile" | sed 's+-incomplete-+-fail-+g')"
          echo "logfile name is $logfile"
          description="OH NO! The ${scripts[$word]} script exited with an error code!\
\nPlease view the log in terminal to find the cause of the error\
\nIf you need help, send the error report to us via the button below to our Discord or create a GitHub issue!\
\n\nContinue running the rest of the your selected Megascript installs or exit the Megascript?"
          table=("Continue and Send Error" "Continue" "Exit and Send Error" "Exit")
          userinput_func "$description" "${table[@]}"
          case "$output" in
            "Exit")
              exit
              ;;
            "Continue and Send Error")
              send_error "$logfile" > /dev/null
              ;;
            "Exit and Send Error")
              send_error "$logfile" > /dev/null
              exit
              ;;
          esac
        else
          status_green "\nInstalled ${friendly[$word]} successfully." | tee -a "$logfile"
          # format_logfile "$logfile" #remove escape sequences from logfile
          mv "$logfile" "$(echo "$logfile" | sed 's+-incomplete-+-success-+g')"
          logfile="$(echo "$logfile" | sed 's+-incomplete-+-success-+g')"
        fi
        unset script_exit_code

        time_script_stop=$(date +%s)
        time_elapsed=$(echo "$time_script_stop - $time_script_start" | bc)
        time_elapsed_friendly=$(eval "echo $(date -ud "@$time_elapsed" +'$((%s/3600/24)) days %H hours %M minutes %S seconds')")
        echo "${scripts[$word]} took $time_elapsed_friendly" >> /tmp/megascript_times.txt        
      else
        # this is legacy use, no current scripts use this function
        eval "${execute[$word]}"
        time_script_stop=$(date +%s)
        time_elapsed=$(echo "$time_script_stop - $time_script_start" | bc)
        time_elapsed_friendly=$(eval "echo $(date -ud "@$time_elapsed" +'$((%s/3600/24)) days %H hours %M minutes %S seconds')")
        echo "${execute[$word]} took $time_elapsed_friendly" >> /tmp/megascript_times.txt  
      fi
    done
  fi
done

if sudo -n true; then
  add_desktop
else
  echo "didn't add the L4T-Megascript.desktop file, sudo timer ran out"
fi

megascript_end_time=$(date +%s)
megascript_elapsed=$(echo "$megascript_end_time - $megascript_start_time" | bc)
megascript_elapsed_friendly=$(eval "echo $(date -ud "@$megascript_elapsed" +'$((%s/3600/24)) days %H hours %M minutes %S seconds')")

if [[ $gui == "gui" ]]; then
  echo -e "Thank you for using the L4T Megascript!\nStop by our Discord server at https://discord.gg/abgW2AG87Z for support.\n\nCredits:\nCobalt - Manager/Lead Dev\nGman - Developer/GUI and CLI Management/RetroPie/Minecraft Handler\nLugsole - Contributor/GUI Manager\nLang Kasempo - Contributor/Beta Tester/did a lot of the standalone game scripts\n\nthe Switchroot L4T Ubuntu team (https://switchroot.org/) - making the actual OS you're running right now\n\nThe Megascript ran for $megascript_elapsed_friendly" \
  |  yad --show-uri --center --image "dialog-information" --borders="20" --title "Bye" \
  --text-info --fontname="@font@ 11" --wrap --width=800 --height=400 \
  --show-uri  --window-icon=/usr/share/icons/L4T-Megascript.png \
  --button="Open the L4T-Megascript Wiki Page":1 \
  --button="Exit the L4T-Megascript":0
  if [[ $? -ne 0 ]]; then
    # spawn a web browser with the wiki
    setsid x-www-browser "https://github.com/cobalt2727/L4T-Megascript/wiki" > /dev/null 2>&1 &
  fi
  clear -x
else
  echo "Thank you for using the L4T Megascript!"
  sleep 2
  clear -x
  echo "Credits:"
  echo "CTRL + CLICK ON A LINK TO OPEN IT"
  echo
  echo -e "\e[38;2;0;71;171mCobalt - Manager/Lead Dev/Benevolent Dictator\e[0m"
  echo -e "\e[32mGman - Developer/GUI and CLI Management/RetroPie/Minecraft Handler\e[0m" 
  echo -e "\e[38;2;$(shuf -i 0-255 -n 1);$(shuf -i 0-255 -n 1);$(shuf -i 0-255 -n 1)mLugsole - Contributor\e[0m"
  echo -e "\e[35mLang Kasempo - Contributor/Beta Tester\e[0m"

  echo -e "All the contributors and beta testers that put up with Cobalt pinging them incessantly"
  #echo "hey, if you're reading this, odds are you probably helped make the thing. you can add your name to the credits in your PRs!"
  echo "the Switchroot L4T Ubuntu team (https://switchroot.org/) - making the actual OS you're running right now"
  echo ""
  echo "The Megascript ran for $megascript_elapsed_friendly"
fi
unset repository_username
unset repository_branch
unset gui

echo ""
echo -e 'Thank you for using the L4T Megascript! Stop by our \e[36mDiscord\e[0m server at https://discord.gg/abgW2AG87Z for support.'
echo 'Source code is available here: https://github.com/cobalt2727/L4T-Megascript/'
