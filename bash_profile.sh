#########################################################################################
# OSX Only
#########################################################################################
function cdl() { cd $1 && command ls -lahF; };
function perms() { stat -f '%A %N' $**; };
alias prms="perms"
alias {perm,prm}="stat -f '%A %N'"
alias hi="echo -e '\e[45mHello there!\e]0m'"
alias prof="code --new-window ~/.profile ~/.bashrc ~/.zshrc ~/.ssh/config ~/ssh_aliases"
alias iterm="open '/Applications/iTerm.app'"
alias ls="command ls -1GF";
alias lsf='command ls -1Gd $PWD/*';
alias lst='command ls -1Gt';
alias ll='command ls -lahGF';
alias llf='command ls -lahGFd $PWD/*';
alias llt='command ls -lahGFt';

#########################################################################################
# ZSH-specific
#########################################################################################
alias {colorzsh,colorz}="export PS1='[%F{black}%K{green} %n %F{reset_color}%K{reset_color}] %F{cyan}%1~%F{reset_color}: '";
alias sh="PS1='[\e[30;43m\u\e[21m@\e[0;30;43m\h\e[0m \e[40;36m$PWD\e[0m]\n' /bin/sh";

#########################################################################################
# OSX & Linux
#########################################################################################

function lll() {
    if [ -z "$1" ];
        then llldir="$PWD";
        else llldir="$1";
    fi;
    find "$llldir" -maxdepth 1 -printf '%.5m %10M %#9u:%-9g %#5U:%-5G [%Y] [%Z] %f %l\n';
};
function mod() {
    if [ -z "$1" ];
        then llldir="$PWD";
        else llldir="$1";
    fi;
    find "$llldir" -maxdepth 1 -printf '%.5m %10M %#9u:%-9g %#5U:%-5G ║%Ar║%Tr║%Cr║ [%Y] [%Z] %f %l\n';
};
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
function perms() { stat -c '%A %n' $**; };
function flatten() {
    if (( $# == 0 ));
        then skim < /dev/stdin | tr -s '\n' ';' | sed 's/;$//g';
    fi;
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

# section
# Description   : prints section from string
# Usage         : awks section-number [delimiter] [string]
# Pipeline input: allowed
# Example       : awks 2 , 'foo,bar'
# Example       : echo 'foo bar' | awks 2
function section() {
    if [ -z $2 ];
        then awk "{print \$$1}";
        else awk -F"$1" "{print \$$1(< /dev/stdin)}";
    fi;
};
alias {awk2,awks}="section"

function col() { sed -r "s/([^ ]+ +){$(($1-1))}([^ ]+).*/\2/"; };
function skim() {
    if (( $# == 0 ));
    then grep -v --color=never '^\s*[#;]\|^\s*$' < /dev/stdin;
    else grep -v --color=never '^\s*[#;]\|^\s*$' "$1";
    fi;
};
function conn() { ssh -t $1 "export vv=\"$(flatten ~/ssh_aliases)\" && bash"; };

function show() {
    if (( $# == 0 ));
    then GREP_COLOR='2;37' command grep --color=always -e '^' -e '\(^\s*[#;]\|^\s*$\).*' < /dev/stdin;
    else GREP_COLOR='2;37' command grep --color=always -e '^' -e '\(^\s*[#;]\|^\s*$\).*' "$1";
    fi;
};
function cdl() { cd $1 && command ls -lahF --color=auto; };
function ssudo() { [[ "$(type -t $1)" == "function" ]] && ARGS="@" && sudo bash -c "$(declare -f $1); $ARGS"; };

alias prof='code --new-window ~/.profile ~/.bashrc ~/.zshrc ~/ssh_aliases';
alias conf='code --new-window ~/.ssh/config ~/.aws/* ~.gitconfig ~/etc/bashrc /etc/zshrc';
alias colorsh="export PS1=' [\e[1;30;43m\u\e[21m@\e[0;30;43m\h\e[0m \e[40;36m\W\e[0m]: '":;
alias {sshlist,sshl}="grep '^Host .*' ~/.ssh/config | cut -c6-";
alias {sshlistfull,sshlfull,sshlf}="cat ~/.ssh/config";

alias ssudo="ssudo ";
alias sudo="sudo ";
alias {skimc,grepc,cgrep}='show ';
alias ls='command ls -1F --color=auto';
alias lsf='command ls -1Gd $PWD/* --color=auto';
alias lsz='command ls -1GdZ $PWD/* --color=auto';
alias ll='command ls -lahF --color=auto';
alias llf='command ls =lahGFd $PWD/* --color=auto';
alias llz='command ls -lahGFdZ $PWD/* --color=auto';
alias {..,up}='cd .. && pwd';
alias down='cdl';
alias grep='grep --color=auto';
alias path='echo -e ${PATH//:/\\n}';
alias perm="stat -c '%A %n'";
alias {public,pub}='echo -en "$(cat $HOME/.ssh/id_rsa.pub)"';
alias {svcfiles,sysfiles}="command ls -l /usr/lib/systemd/system/ /run/systemd/system/ /etc/systemd/system/ | egrep 'service([^\.]|$)' | awk '{print \$9}";
alias {svcf,sysf}="find /usr/lib/systemd/system/ /run/systemd/system/ /etc/systemd/system/ -name 'service([^\.]|$)' | awk '{print \$9}' | sort";
alias {svc,sys}="systemctl --type=service";
alias {svcon,syson}="systemctl --type-service --state=active";
alias {svcoff,sysoff}="systemctl --type-service --state=failed";
alias {whoin,listening}="(netstat -tulpn | grep ESTABLISHED | tr -s ' ' |cut -f5 -d ' '";
alias {whoout,connected}="netstat -ant | grep ESTABLISHED | tr -s ' ' | cut -f5 -d ' '";
alias {whatip,ips}='ip a | grep inet | awk "{print \$2}" |GREP_COLOR=2 grep "/.*" --color=always';
alias coloron="reset='\e[0m' default='\e[39m' white='\e[97m black='\e[30m' red='\e[31m' green='\e[32m; yellow='\e[33m' blue='\e[34m' magenta='\e[35m' cyan='\e[36m' lgray='\e[37m' dgray='\e[90m' lred='\e[91m' lgreen='\e[92m' lyellow='\e[93m' lblue='\e[94m' lmagenta='\e[95m' lcyan='\e[96m' bdefault='\e[49m' bblack='\e[40m' bred='\e[41m' bgreen='\e[42m' byellow='\e[43m' bblue='\e[44m' bmagenta='\e[45m' bcyan='\e[46m' blgray='\e[47m' bdgray='\e[100m' blred='\e[101m' blgreen='\e[102m' blyellow='\e[103m' bblue='\e[104m' blmagenta='\e[105m' blcyan='\e[106m' bwhite='\e[107m' bold='\e[1m' dim='\e[2m' underline='\e[4m' blink='\e[5m' invert='\e[7m' hide='\e[8m' nof='\e[0m' nobold='\e[21m' nodim='\e[22m' nounderline='\e[24m' noblink='\e[25m' noinvert='\e[27m' nohide='\e[28m';echo -en \"${bgreen}___TEST___\"";
alias coloroff="unset reset default white black red green yellow blue magenta cyan lgray dgray lred lgreen lyellow lblue lmagenta lcyan bdefault bblack bred bgreen byellow bblue bmagenta bcyan blgray bdgray blred blgreen blyellow bblue blmagenta blcyan bwhite bold dim underline blink invert hide nof nobold nodim nounderline noblink noinvert nohide;echo -en ${bgreen}___TEST___";
alias {route,routes}='netstat -rn';
alias tnet='nc -zv';
alias sshgen="ssh-keygen -N '' -f \"$PWD/id_rsa\" <<<y && echo \"$PWD/id_rsa\" && echo 'Below is the public key:' && cat \"$PWD/id_rsa.pub\"";
alias cdev='export PS1="[\e[30;43m\u\e[21m@\e[0;30;43m\h\e[0m \e[40;36m\w\e[0m]\n"';
alias cprod='export PS1="[\e[41;97m\u\e[21m@\e[0;41;97m\h\e[0m \e[40;36m\w\e[0m]\n"';
alias dequote="sed \"/\'/┐/g; s/\"/╗/g\"";
alias requote="sed \"/┐/\'/g; s/╗/\"/g\"";
alias k='kubectl'
