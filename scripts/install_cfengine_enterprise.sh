#!/bin/bash
TYPE=$1

echo "Checking for CFEngine Enterprise $TYPE"
if [[ $TYPE == "agent" ]]; then
    if $(/bin/rpm --query --quiet cfengine-nova); then
        echo "CFEngine Enterprise $TYPE is already installed"
    else
        echo "Installing CFEngine Enterprise $TYPE"
        rm  -f /home/vagrant/cfengine-nova-hub*
        rpm -i /home/vagrant/cfengine-nova*.rpm
    fi
elif [[ $TYPE == "hub" ]]; then
    if $(/bin/rpm --query --quiet cfengine-nova-nova); then
        echo "CFEngine Enterprise $TYPE is already installed"
    else
        echo "Installing CFEngine Enterprise $TYPE"
        rpm -i /home/vagrant/cfengine-nova-hub*.rpm
    fi
else
  echo "'$TYPE' is not a valid CFEngine package type."
fi
