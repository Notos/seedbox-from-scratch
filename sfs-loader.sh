##################### FIRST LINE
# ---------------------------
#!/bin/bash
# ---------------------------

# 1.
clear
echo "Installing some important packages..."
#try to force install of some useful packages
sudo apt-get --yes install whois sudo git makepasswd &> /dev/null
apt-get --yes install whois sudo git makepasswd &> /dev/null
clear

# 1.1 functions

function getString()
{
  local NEWVAR1=a
  local NEWVAR2=b
  while [ ! $NEWVAR1 = $NEWVAR2 ];
  do
    echo ""
    read -e -i "$3" -p "$1" NEWVAR1
    if [ "$NEWVAR1" == "$3" ]
    then
      NEWVAR2=$NEWVAR1
    else
      read -p "Retype: " NEWVAR2
    fi
    if [ ! $NEWVAR1 = $NEWVAR2 ]
    then
      echo "$NEWVAR1 is not equal to $NEWVAR2"
      echo ""
    fi
  done
  eval $2=\$NEWVAR1
}
function getPassword()
{
  local NEWVAR1=a
  local NEWVAR2=b
  while [ ! $NEWVAR1 = $NEWVAR2 ];
  do
    echo ""
    read -s -p "$1" NEWVAR1
    echo ""
    read -s -p "Retype: " NEWVAR2
    echo ""

    if [ ! $NEWVAR1 = $NEWVAR2 ]
    then
      echo "$NEWVAR1 is not equal to $NEWVAR2"
      echo ""
    fi
  done
  eval $2=\$NEWVAR1
}

# 1.2 create new user

if [ "$USER" = "root" ]
then
  echo "You cannot install as root, let's select a new user for you."
  unset NEWUSER1
  echo ""
else
  NEWUSER1=$USER
  echo "You are $NEWUSER1, it's a good username, but are you sure this is the user you want to use?"
  echo ""
fi

getString "Type your seedbox username to be used or created: " NEWUSER1 $NEWUSER1

if [ $NEWUSER1 = "root" ]
then
  echo "You are trying to force root. This script is ended."
  exit
fi

getPassword "Type a password for user $NEWUSER1: " PASSWORD1

if [ "$USER" = "root" ]
then
  /usr/sbin/useradd --create-home --user-group --password $(mkpasswd -s -m md5 $PASSWORD1) --shell /bin/bash $NEWUSER1 &> /dev/null
  echo "$NEWUSER1 ALL=(ALL:ALL) ALL" | tee -a /etc/sudoers &> /dev/null
else
  sudo /usr/sbin/useradd --create-home --user-group --password $(mkpasswd -s -m md5 $PASSWORD1) --shell /bin/bash $NEWUSER1 &> /dev/null
  echo "$NEWUSER1 ALL=(ALL:ALL) ALL" | sudo tee -a /etc/sudoers &> /dev/null
fi

DIR=$(pwd)
sudo su --login $NEWUSER1 -c '$DIR/sfs-runner.sh "$NEWUSER1" "$PASSWORD1" '

# ----------------------------------
##################### LAST LINE ----
