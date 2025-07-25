alias src='source ~/.bash_aliases';
alias {srcver,srcv}='echo bash_aliases v42';
function sshgenc() {
    read "comment?Enter desired comment: ";
    read "filename?Enter file name (default is \"$(echo $PWD/id_rsa | tr -s '/')\"): ";
    if [ -z "$comment" ];
        then comment= && echo "comment= \"$comment\"";
    fi;
    if [ -z "$filename" ];
        then filename="$PWD/id_rsa" && echo "filename= \"$filename\"";
    fi;
    ssh-keygen -C "$comment" -f $filename $@;
};
function delhost() {
    if (( $# == 0 ));
        then host_to_del=$(< /dev/stdin);
        else host_to_del="$1";
    fi;
    (sed -i "/$host_to_del/d; /^$/d" $HOME/.ssh/known_hosts && \
    return "\"$host_to_del\" removed from $HOME/.ssh/known_hosts:\n") || \
    (return "unable to remove \"$host_to_del\"\n");
};
alias rmhost='delhost'
function section() {
    if [ -z $2 ];
        then awk "{print \$$1}";
        else awk -F"$1" "{print \$$1(< /dev/stdin)}";
    fi;
};
function col() { sed -r "s/([^ ]+ +){$(($1-1))}([^ ]+).*/\2/"; };
function cdl() { cd $1 && ls -lahF --color=auto; };
function ssudo() { [[ "$(type -t $1)" == "function" ]] && ARGS="@" && sudo bash -c "$(declare -f $1); $ARGS"; };
alias {sshlist,sshl}="grep '^Host .*' ~/.ssh/config | cut -c6-";
alias {sshlistfull,sshlfull,sshlf}="cat ~/.ssh/config";
alias ssudo="ssudo ";
alias sudo='sudo ';
alias ls='ls -1F --color=auto';
alias lsf='ls -1Gd $PWD/* --color=auto';
alias lsz='ls -1GdZ $PWD/* --color=auto';
alias ll='ls -lahF --color=auto';
alias llf='ls -lahGFd $PWD/* --color=auto';
alias llz='ls -lahGFdZ $PWD/* --color=auto';
alias {..,up}='cd ..';
alias {...,..2,up2}='cd ../..';
alias {....,..3,up3}='cd ../../..';
alias {.....,..4,up4}='cd ../../../..';
alias path='echo -e ${PATH//:/\\n}';
alias perms="stat -c '%a %A %n'";
alias {mypublic,mypub}='cat $HOME/.ssh/id_rsa.pub';
alias {public,pub}='cat $HOME/.ssh/authorized_keys';
alias {svcfiles,sysfiles}="ls -l /usr/lib/systemd/system/ /run/systemd/system/ /etc/systemd/system/ | egrep 'service([^\.]|$)' | awk '{print $9}'";
alias {svcfilesold,sysfilesold}="ls -l /etc/systemd/system/* && ls -l /run/systemd/system/* && ls -l /lib/systemd/system/*"
alias {appfiles,packagefiles}="dpkg -L $1"
alias {svc,sys}="systemctl list-units --type=service";
alias {svcold,sysold}='sudo service --status-all'
alias {svcon,syson}="systemctl list-units --state=active";
alias {svcoff,sysoff}="systemctl list-units --state=failed";
alias listening="netstat -tulpn | grep LISTEN";
alias whoin="netstat -tulpn | grep ESTABLISHED | tr -s ' ' | cut -f5 -d ' '";
alias {whoout,connected}="netstat -ant | grep ESTABLISHED | tr -s ' ' | cut -f5 -d ' '";
alias {whatip,ips}='ip a | grep inet | awk "{print \$2}" |GREP_COLOR=2 grep "/.*" --color=always';
alias coloron="reset='\e[0m' default='\e[39m' white='\e[97m' black='\e[30m' red='\e[31m' green='\e[32m' yellow='\e[33m' blue='\e[34m' magenta='\e[35m' cyan='\e[36m' lgray='\e[37m' dgray='\e[90m' lred='\e[91m' lgreen='\e[92m' lyellow='\e[93m' lblue='\e[94m' lmagenta='\e[95m' lcyan='\e[96m' bdefault='\e[49m' bblack='\e[40m' bred='\e[41m' bgreen='\e[42m' byellow='\e[43m' bblue='\e[44m' bmagenta='\e[45m' bcyan='\e[46m' blgray='\e[47m' bdgray='\e[100m' blred='\e[101m' blgreen='\e[102m' blyellow='\e[103m' bblue='\e[104m' blmagenta='\e[105m' blcyan='\e[106m' bwhite='\e[107m' bold='\e[1m' dim='\e[2m' underline='\e[4m' blink='\e[5m' invert='\e[7m' hide='\e[8m' nof='\e[0m' nobold='\e[21m' nodim='\e[22m' nounderline='\e[24m' noblink='\e[25m' noinvert='\e[27m' nohide='\e[28m'";
alias coloroff="unset reset default white black red green yellow blue magenta cyan lgray dgray lred lgreen lyellow lblue lmagenta lcyan bdefault bblack bred bgreen byellow bblue bmagenta bcyan blgray bdgray blred blgreen blyellow bblue blmagenta blcyan bwhite bold dim underline blink invert hide nof nobold nodim nounderline noblink noinvert nohide";
alias {route,routes}='netstat -rn';
alias tnet='nc -zv';
alias sshgen="ssh-keygen -N '' -f \"$PWD/id_rsa\" <<<y && echo \"$PWD/id_rsa\" && echo 'Below is the public key:' && cat \"$PWD/id_rsa.pub\"";
alias sh="PS1='\$' /bin/sh";
function ec2info() { curl $(echo "http://169.254.169.254/latest/meta-data/$1"); echo -en '\n'; };
alias {ec2i,awsinfo,awsi}="ec2info";
alias grep='grep --color=auto';
alias skim="grep -v '^\s*[#;]\|^\s*$'";
alias skimc="GREP_COLOR='2;32' grep --color=always -e '^' -e '\(^\s*[#;]\|^\s*$\).*'";
function catline() {
    if [ -z $1 ]; then echo -e '\e[31mError:\e[37m catline usage: catline [file] line_number(s)' && return 1;
    elif [ -z $2 ]; then sed -n $(tr '-' ',' <<< $1)p;
    else sed -n $(tr '-' ',' <<< $2)p $1;
    fi;
};
alias line='catline';
alias {vimline,vimat}="vim +$1";
alias untar='tar -xzvf'
alias findstartup="grep -r $1 ~/.bashrc ~/.bash_profile ~/.bash_aliases ~/.bash_logout ~/.inputrc ~/.profile ~/.bash_completion /etc/profile /etc/bash.bashrc /etc/inputrc /etc/skel/ /etc/profile.d/"
