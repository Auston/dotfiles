autoload -U promptinit
promptinit
prompt adam2    #prompt -p 查看提示符样式

autoload -Uz compinit   #开启自动补全
compinit

bindkey -e    #Emacs风格键绑定 Ctrl+a Ctrl+e
bindkey "\e[3~" delete-char     #设置 [DEL]键 为向后删除

export HISTFILE=~/.zsh_history  # location of history
export HISTSIZE=10000000  # number of lines kept in history
export SAVEHIST=10000000  # number of lines saved in the history after logout
setopt share_history      # share history among sessions
setopt extended_history
export SUDO_PROMPT=$'[\e[31;5msudo\e[m] password for \e[33;1m%p\e[m: '

export EDITOR="vim"
export VISUAL="vim"
export BROWSER="firefox"

#Put all alias definitions into a separate file
if [ -f ~/.aliases ]; then
    . ~/.aliases
fi

##路径别名  进入相应的路径时只要 cd ~xxx
hash -d windows="/home/music"
hash -d backup="/home/backup"
hash -d pdf="/home/music/Documents/PDF"
#hash -d arch="/mnt/arch"
#hash -d PKG="/var/cache/pacman/pkg"
#hash -d E="/etc/env.d"
#hash -d C="/etc/conf.d"
#hash -d I="/etc/rc.d"
#hash -d X="/etc/X11"


#文件关联
alias -s pdf=foxitreader        #pdf文件用foxitreader打开,下同
alias -s txt=vim
for i in jpg png;    alias -s $i=gqview
for i in avi mp4 rmvb wmv m4v mov mkv;      alias -s $i=mplayer

# 设置参数
setopt auto_cd # if not a command, try to cd to it.
setopt auto_pushd # automatically pushd directories on dirstack  #启用cd 命令的历史纪录,cd -[TAB]进入历史路径
setopt auto_continue #automatically send SIGCON to disowned jobs
setopt extended_glob # so that patterns like ^() *~() ()# can be used
setopt pushd_ignore_dups # do not push dups on stack
setopt pushd_silent # be quiet about pushds and popds
setopt brace_ccl # expand alphabetic brace expressions
setopt complete_in_word # stays where it is and completion is done from both ends
setopt correct # spell check for commands only
setopt no_hist_beep # don not beep on history expansion errors
setopt hash_list_all # search all paths before command completion
setopt hist_ignore_all_dups # when runing a command several times, only store one
setopt hist_reduce_blanks # reduce whitespace in history
setopt hist_ignore_space # do not remember commands starting with space
setopt hist_verify # reload full command when runing from history
setopt hist_expire_dups_first #remove dups when max size reached
setopt interactive_comments # comments in history
setopt list_types # show ls -F style marks in file completion
setopt long_list_jobs # show pid in bg job list
setopt numeric_glob_sort # when globbing numbered files, use real counting
setopt inc_append_history # append to history once executed
setopt prompt_subst # prompt more dynamic, allow function in prompt
setopt nonomatch 

#路径补全
zstyle ':completion:*' expand 'yes'
zstyle ':completion:*' squeeze-shlashes 'yes'
zstyle ':completion::complete:*' '\\'

#自动补全功能
setopt AUTO_LIST
setopt AUTO_MENU

#修正大小写
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'

#彩色补全菜单 
eval $(dircolors -b) 
export ZLSCOLORS="${LS_COLORS}"
zmodload zsh/complist
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'

#kill 命令补全  不用再输入数字了><
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:*:kill:*:processes' list-colors "=(#b) #([0-9]#)*=36=1;31"
zstyle ':completion:*:*:*:*:processes' force-list always
zstyle ':completion:*:processes' command 'ps -au$USER'

# 补全之后 类型提示分组  这个好强大~ 
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:descriptions' format $'\e[33m == \e[1;7;36m %d \e[m\e[33m ==\e[m'
zstyle ':completion:*:messages' format $'\e[33m == \e[1;7;36m %d \e[m\e[0;33m ==\e[m'
zstyle ':completion:*:warnings' format $'\e[33m == \e[1;7;31m No Matches Found \e[m\e[0;33m ==\e[m'
zstyle ':completion:*:corrections' format $'\e[33m == \e[1;7;37m %d (errors: %e) \e[m\e[0;33m ==\e[m'

##在命令前插入 sudo 
#{{{
##定义功能 
sudo-command-line() {
    [[ -z $BUFFER ]] && zle up-history
    [[ $BUFFER != sudo\ * ]] && BUFFER="sudo $BUFFER"
    zle end-of-line                 #光标移动到行末
}
zle -N sudo-command-line
#定义快捷键为： [Esc] [Esc]
bindkey "\e\e" sudo-command-line
#}}}

#[Esc][h] man 当前命令时，显示简短说明
alias run-help >&/dev/null && unalias run-help
autoload run-help

#Colored Man Pages
export PAGER=less
export LESS_TERMCAP_md=$'\E[1;31m' #bold1
export LESS_TERMCAP_mb=$'\E[1;31m'
export LESS_TERMCAP_me=$'\E[m'
export LESS_TERMCAP_so=$'\E[01;7;34m' #search highlight
export LESS_TERMCAP_se=$'\E[m'
export LESS_TERMCAP_us=$'\E[1;2;32m' #bold2
export LESS_TERMCAP_ue=$'\E[m'
export LESS="-M -i -R --shift 5"
export LESSCHARSET=utf-8
export READNULLCMD=less]

##zsh中让敲出来的命令带颜色  http://roylez.heroku.com/2010/10/24/zsh-command-color.html
#{{{
TOKENS_FOLLOWED_BY_COMMANDS=('|' '||' ';' '&' '&&' 'sudo' 'do' 'time' 'strace')

recolor-cmd() {
    region_highlight=()
    colorize=true
    start_pos=0
    for arg in ${(z)BUFFER}; do
        ((start_pos+=${#BUFFER[$start_pos+1,-1]}-${#${BUFFER[$start_pos+1,-1]## #}}))
        ((end_pos=$start_pos+${#arg}))
        if $colorize; then
            colorize=false
            res=$(LC_ALL=C builtin type $arg 2>/dev/null)
            case $res in
                *'reserved word'*)   style="fg=magenta,bold";;
                *'alias for'*)       style="fg=cyan,bold";;
                *'shell builtin'*)   style="fg=yellow,bold";;
                *'shell function'*)  style='fg=green,bold';;
                *"$arg is"*)         
                    [[ $arg = 'sudo' ]] && style="fg=red,bold" || style="fg=blue,bold";;
                *)                   style='none,bold';;
            esac
            region_highlight+=("$start_pos $end_pos $style")
        fi
        [[ ${${TOKENS_FOLLOWED_BY_COMMANDS[(r)${arg//|/\|}]}:+yes} = 'yes' ]] && colorize=true
        start_pos=$end_pos
    done
}

check-cmd-self-insert() { zle .self-insert && recolor-cmd }
check-cmd-backward-delete-char() { zle .backward-delete-char && recolor-cmd }

zle -N self-insert check-cmd-self-insert
zle -N backward-delete-char check-cmd-backward-delete-char
#}}}

# 一些普通的自定义函数
256tab() {
    for k in `seq 0 1`;do
        for j in `seq $((16+k*18)) 36 $((196+k*18))`;do
            for i in `seq $j $((j+17))`; do
                printf "\e[01;$1;38;5;%sm%4s" $i $i;
            done;echo;
        done;
    done
}

# 补全类型控制
# ex [tab] 的候选菜单中只出现扩展名为设定的文件
compctl -g '*.tar.bz2 *.tar.gz *.bz2 *.gz *.xz *.rar *.tar *.tbz2 *.tgz *.zip *.7z *.Z' + -g '*(-/)' ex
compctl -g '*.pdf' + -g '*(-/)' zathura

ex () {
    if [[ -z "$1" ]] ; then
           print -P "usage: \e[1;36mex\e[1;0m < filename >"
           print -P "       Extract the file specified based on the extension"
    elif [[ -f $1 ]] ; then
       case $1 in
         *.tbz2 | *.tar.bz2)  tar xjfv   $1    ;;
         *.tgz  | *.tar.gz)   tar xzfv   $1    ;;
         *.tar  | *.cbt)      tar xf     $1    ;;
         *.zip  | *.cbz)      unzip      $1    ;;
         *.bz2)               bunzip2 v  $1    ;;
         *.xz)                unxz       $1    ;;
         *.rar)               rar x      $1    ;;
         *.gz)                gunzip     $1    ;;
         *.7z)                7z x       $1    ;;
         *.Z)                 uncompress $1    ;;
         *)           echo "'$1' cannot be extracted via extract()" ;;
       esac
   else
     echo "'$1' is not a valid file"
   fi
}

fy () {
    w3m -no-cookie -dump 'http://dict.baidu.com/s?wd='$1'&f=3'  \
    | sed '/以下结果来自互联网网络释义/,$d'| sed '1,15d' | tac \
    | sed '1,2d' | tac |sed -r '/^[0-9]+\./N;s/\n//'>/tmp/rxdict.tmp
    cat /tmp/rxdict.tmp
}
