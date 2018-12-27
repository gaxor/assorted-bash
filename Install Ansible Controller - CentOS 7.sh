#!/bin/bash

# Install Ansible on local CentOS machine
# Downloads Ansible playbooks from a git server that is no longer available
# By Greg Rowe May 2017

# vars
domain=DOMAIN.LOCAL
playbook_name=AnsibleController.yml
playbook_uri="https://git.domain.com/ansible/raw/master/Ansible%20Playbooks/$playbook_name"

# Print horizontal ruler with message
printline ()
{
 if [ $# -eq 0 ]; then
   echo "Usage: printline MESSAGE [COLOR_CODE] [RULE_CHARACTER]"
   return 1
 fi
# Fill line with ruler character ($3, default "-"), reset cursor, move 2 cols right, print message
 echo -e $2
 printf -v _hr "%*s" $(tput cols) && echo -en ${_hr// /${3--}} && echo -e "\r\033[2C$1"
 echo -e '\e[0m'
}

# Color declaration for echo
WHI='\e[0m'
RED='\e[91m'
YEL='\e[93m'
BLU='\e[34m'
MAG='\e[95m'
GRE='\e[92m'
CYA='\e[96m'

# Warn if script is running as root
if [[ $(/usr/bin/id -u) -eq 0 ]]; then
 printline " This script is intended to run as a standard user (not root). " $RED
 exit
fi

# Prompt user for variables
printline " ${YEL} Enter your domain username (e.g. ${CYA}jdoe${YEL}): " $CYA
read username

kerberos_username="$username@${domain^^}"

printline " ${YEL}Enter the password for ${CYA}$kerberos_username${YEL}): " $CYA
read -s kerberos_password

printline " ${YEL}Enter your Git token: " $CYA
read token

printline " ${YEL}Enter your AWS Access Key ID (e.g. ${CYA}AKIAIOSFODNN7EXAMPLE${YEL}): " $CYA
read aws_access_key_id

printline " ${YEL}Enter your AWS Secret Key (e.g. ${CYA}wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY${YEL}): " $CYA
read aws_secret_access_key

printline " Enter your local linux user's password " $CYA
echo -e ${YEL}
sudo echo -e ${WHI}

# Ansible prep & install tasks
printline " Installing necessary packages " $CYA
sudo yum -y -t install epel-release
sudo yum -y -t install ansible

printline " Download playbook " $CYA
sudo curl $playbook_uri?private_token=$token -o /etc/ansible/$playbook_name

printline " Customize playbook for current user " $CYA

# Customize playbook
sudo sed -i -E 's#(domain_username:\s\").*[^\"]#\1\'$kerberos_username# /etc/ansible/$playbook_name
sudo sed -i -E 's#(aws_access_key_id:\s\").*[^\"]#\1\'$aws_access_key_id# /etc/ansible/$playbook_name
sudo sed -i -E 's#(aws_secret_access_key:\s\").*[^\"]#\1\'$aws_secret_access_key# /etc/ansible/$playbook_name
sudo sed -i -E 's#(local_user:\s\").*[^\"]#\1\'$USER# /etc/ansible/$playbook_name

# Add localhost to ansible hosts file (required for running playbooks locally)
string=$(sudo cat /etc/ansible/hosts | grep "localhost ansible_connection=local" )
if [[ $string != "localhost ansible_connection=local" ]];then
 sudo su -c "cp /etc/ansible/hosts /etc/ansible/hosts.bak"
 sudo su -c "echo 'localhost ansible_connection=local' > /etc/ansible/hosts"
fi

# Run playbook
printline " Run Ansible playbook to configure localhost as an Ansible controller " $CYA
sudo ansible-playbook /etc/ansible/$playbook_name

# Kerberos ticket setup
printline " Set up Kerberos ticket for domain authentication " $CYA

kdestroy
rm ~/$kerberos_username.keytab

printf "%b" "addent -password -p $kerberos_username -k 1 -e aes256-cts-hmac-sha1-96\n$kerberos_password\nwrite_kt $kerberos_username.keytab" | ktutil
printf "%b" "read_kt $kerberos_username.keytab\nlist -t" | ktutil

echo -e ${RED}
kinit $kerberos_username -k -t $kerberos_username.keytab
echo -e ${MAG}
klist
echo -e ${WHI}

# Set hostname (optional)
#sudo hostnamectl set-hostname $username-ansible

printline " Complete! " $CYA
exec sudo su -l $USER
