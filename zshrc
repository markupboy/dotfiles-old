function precmd {
	local TERMWIDTH
	(( TERMWIDTH = ${COLUMNS} - 1 ))
	PR_FILLBAR=""
	PR_PWDLEN=""
	local promptsize=${#${(%):---(%n@%m:%l)---()--}}
	local pwdsize=${#${(%):-%~}}
	if [[ "$promptsize + $pwdsize" -gt $TERMWIDTH ]]; then
		((PR_PWDLEN=$TERMWIDTH - $promptsize))
	else
		PR_FILLBAR="\${(l.(($TERMWIDTH - ($promptsize + $pwdsize)))..${PR_HBAR}.)}"
	fi
}


git_prompt() {
  unset __CURRENT_GIT_BRANCH
  unset __CURRENT_GIT_BRANCH_STATUS
  unset __CURRENT_GIT_BRANCH_IS_DIRTY

  local st="$(git status 2>/dev/null)"
  if [[ -n "$st" ]]; then
    local -a arr
    arr=(${(f)st})

    if [[ $arr[1] =~ 'Not currently on any branch.' ]]; then
      __CURRENT_GIT_BRANCH='no-branch'
    else
      __CURRENT_GIT_BRANCH="${arr[1][(w)4]}";
    fi

    if [[ $arr[2] =~ 'Your branch is' ]]; then
      if [[ $arr[2] =~ 'ahead' ]]; then
        __CURRENT_GIT_BRANCH_STATUS='ahead'
      elif [[ $arr[2] =~ 'diverged' ]]; then
        __CURRENT_GIT_BRANCH_STATUS='diverged'
      else
        __CURRENT_GIT_BRANCH_STATUS='behind'
      fi
    fi

    if [[ ! $st =~ 'nothing to commit' ]]; then
      __CURRENT_GIT_BRANCH_IS_DIRTY='1'
    fi
  fi
    
  

  if [ -n "$__CURRENT_GIT_BRANCH" ]; then
    local s="$PR_CYAN("
    s+="$PR_GREEN$__CURRENT_GIT_BRANCH"
    case "$__CURRENT_GIT_BRANCH_STATUS" in
      ahead)
      s+="↑"
      ;;
      diverged)
      s+="↕"
      ;;
      behind)
      s+="↓"
      ;;
    esac
    if [ -n "$__CURRENT_GIT_BRANCH_IS_DIRTY" ]; then
      s+="⚡"
    fi
    s+="$PR_CYAN)"

  echo $s
  fi
}


setprompt () {
	setopt prompt_subst
	autoload colors zsh/terminfo
	if [[ "$terminfo[colors]" -ge 8 ]]; then
		colors
	fi
	for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
		eval PR_$color='%{$fg[${(L)color}]%}'
		eval PR_LIGHT_$color='%{$fg[${(L)color}]%}'
		(( count = $count + 1 ))
	done
	PR_NO_COLOUR="%{$terminfo[sgr0]%}"
	typeset -A altchar
	set -A altchar ${(s..)terminfo[acsc]}
	PR_SET_CHARSET="%{$terminfo[enacs]%}"
	PR_SHIFT_IN="%{$terminfo[smacs]%}"
	PR_SHIFT_OUT="%{$terminfo[rmacs]%}"
	PR_HBAR=${altchar[q]:--}
	PR_ULCORNER=${altchar[l]:--}
	PR_LLCORNER=${altchar[m]:--}
	PR_LRCORNER=${altchar[j]:--}
	PR_URCORNER=${altchar[k]:--}
	case $TERM in
		xterm*)	PR_TITLEBAR=$'%{\e]0;%(!.-=*[ROOT]*=- | .)%n@%m:%~ | ${COLUMNS}x${LINES} | %y\a%}';;
		screen) PR_TITLEBAR=$'%{\e_screen \005 (\005t) | %(!.-=[ROOT]=- | .)%n@%m:%~ | ${COLUMNS}x${LINES} | %y\e\\%}';;
		*) PR_TITLEBAR='';;
	esac

  PROMPT='$PR_SET_CHARSET$PR_STITLE${(e)PR_TITLEBAR}\
$PR_CYAN$PR_SHIFT_IN$PR_ULCORNER$PR_CYAN$PR_HBAR$PR_SHIFT_OUT(\
$PR_GREEN%$PR_PWDLEN<...<%~%<<\
$PR_CYAN)$PR_SHIFT_IN$PR_HBAR$PR_CYAN$PR_HBAR${(e)PR_FILLBAR}$PR_CYAN$PR_HBAR$PR_SHIFT_OUT
$PR_CYAN$PR_SHIFT_IN$PR_LLCORNER$PR_CYAN$PR_HBAR$PR_SHIFT_OUT\
${(e)PR_APM}$PR_GREEN$(git_prompt)\
$PR_CYAN$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT◊\
$PR_NO_COLOUR '

  # RPROMPT=' $PR_CYAN◊$PR_SHIFT_IN$PR_HBAR$PR_CYAN$PR_HBAR$PR_SHIFT_OUT\
# ($PR_GREEN%W$PR_CYAN)$PR_SHIFT_IN$PR_HBAR$PR_CYAN$PR_LRCORNER$PR_SHIFT_OUT$PR_NO_COLOUR'

  PS2='$PR_CYAN$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT\
$PR_CYAN$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT(\
$PR_MAGENTA%_$PR_CYAN)$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT\
$PR_CYAN$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT$PR_NO_COLOUR '

#   PROMPT='$PR_CYAN($PR_GREEN%$PR_PWDLEN<...<%~%<<$PR_CYAN)\
# ${(e)PR_APM} $PR_CYAN$(git_prompt) $PR_NO_COLOUR'
}

setprompt

#completion
zmodload zsh/complist
autoload -Uz compinit && compinit

#correction
setopt correct
setopt correctall

setopt extended_glob

setopt HIST_NO_STORE # don't save 'history' cmd in history
setopt SHARE_HISTORY # share history between open shells

zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path ~/.zsh/cache/$HOST
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-prompt '%SAt %p: Hit TAB for more, or the character to insert%s'
zstyle ':completion:*' menu select=1 _complete _ignored _approximate
zstyle -e ':completion:*:approximate:*' max-errors \
    'reply=( $(( ($#PREFIX+$#SUFFIX)/2 )) numeric )'
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
zstyle ':completion:*::::' completer _expand _complete _ignored _approximate
zstyle -e ':completion:*:approximate:*' max-errors \
    'reply=( $(( ($#PREFIX+$#SUFFIX)/2 )) numeric )'
zstyle ':completion:*:expand:*' tag-order all-expansions
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format ' -%B%d%b- '
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:*:kill:*:processes' command 'ps --forest -A -o pid,user,cmd'
zstyle ':completion:*:processes-names' command 'ps axho command'

###########
# aliases #
###########
#commands
alias ack='ack'
alias s='screen'
alias h='history'
alias o='open'
alias vim='nocorrect vim'
alias mate='nocorrect mate'
alias m='mate'
alias touch='nocorrect touch'
alias mv='nocorrect mv -i'    # no spelling correction on mv
alias cp='nocorrect cp'       # no spelling correction on cp
alias mkdir='nocorrect mkdir' # no spelling correction on mkdir
alias rm='rm -i'
alias ls='ls -G'
alias ll='ls -lahG'
alias extract='smartextract'
alias ip='getIP'
alias c='clear'
alias getpath='pwd|tr -d "\r\n"|pbcopy'

#git
alias dcommit='git svn dcommit'
alias svnrebase='git svn rebase'
alias checkout='git checkout'
alias co='git checkout'
alias rebase='git rebase'
alias commit='git commit'
alias push='git push'
alias pull='git pull'
alias merge='git merge'
alias status='git status'

#advanced git
getBranch() {
	if [[ -n "$1" ]]; then
		branch=$1
	else 
		st="$(git status 2>/dev/null)"
		arr=(${(f)st})
		__CURRENT_GIT_BRANCH="${arr[1][(w)4]}";
		branch=$__CURRENT_GIT_BRANCH
	fi
	echo $branch
}

remaster () { 
	branch=`getBranch $1`
	git checkout master; pull; checkout $branch; rebase master; 
}
mergepush () { 
	branch=`getBranch $1`
	git checkout master; merge $branch; push; checkout $branch; 
}

#mysql
alias mysqlstart='launchctl load -w /usr/local/Cellar/mysql/5.1.49/com.mysql.mysqld.plist'
alias mysqlstop='launchctl unload -w /usr/local/Cellar/mysql/5.1.49/com.mysql.mysqld.plist'
alias mampmysql='/Applications/MAMP/Library/bin/mysql'
#django
alias runserver='python manage.py runserver'
alias syncdb='pyhton manage.py syncdb'
alias migrate='python manage.py migrate'
alias schemamigration='python manage.py schemamigration'
#mercurial
alias hg='/usr/local/Cellar/python/2.6.5/bin/hg'
#directories
alias clients='cd ~/Sites/viget/clients'


LS_COLORS='no=00:fi=00:di=09;33:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jpg=01;35:*.gif=01;35:*.bmp=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.png=01;35:*.mpg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:'
 
export LS_COLORS


# enable and configure the history
setopt APPEND_HISTORY			# append the history file (!important for using multiple zsh sessions)
setopt SHARE_HISTORY			# use commands history files used by different zsh sessions
setopt HIST_IGNORE_DUPS		# ignore adjacent duplicate commands

HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.history
DIRSTACKSIZE=20

#keybindings
bindkey "^?" backward-delete-char
bindkey "^[[3~" delete-char
bindkey '^[OH' beginning-of-line
bindkey '^[OF' end-of-line
bindkey '^[[5~' up-line-or-history
bindkey '^[[6~' down-line-or-history
bindkey "^r" history-incremental-search-backward
bindkey ' ' magic-space			# also do history expansion on space
bindkey '^I' complete-word	# complete on tab, leave expansion to _expand

#  User-defined Functions

# Usage: smartextract <file>
# Description: extracts archived files / mounts disk images
# Note: .dmg/hdiutil is Mac OS X-specific.
smartextract () {
	if [ "$*" -eq "" ]
	then
		echo 'usage: smartextract file ...'
	else
		while [ "$1" != "" ]; do
			case $1 in
				*.tar.bz2)  tar -jxvf $1        ;;
				*.tar.gz)   tar -zxvf $1        ;;
				*.bz2)      bunzip2 $1          ;;
				*.dmg)      hdiutil mount $1    ;;
				*.gz)       gunzip $1           ;;
				*.tar)      tar -xvf $1         ;;
				*.tbz2)     tar -jxvf $1        ;;
				*.tgz)      tar -zxvf $1        ;;
				*.zip)      unzip $1            ;;
				*.Z)        uncompress $1       ;;
				*)          echo "'$1' cannot be extracted/mounted via smartextract()" ;;
			esac
			shift
		done
	fi
}

getIP () {
	ifconfig en0 | grep netmask | awk '{print "lan: "$2}'
	ifconfig en1 | grep netmask | awk '{print "wifi: "$2}'
}

if [ -e /usr/share/terminfo/x/xterm-256color ]; then
	export TERM='xterm-256color'
else
    export TERM='xterm-color'
fi

export PATH="/usr/local/bin:/usr/local/sbin:/usr/local/git/libexec/git-core:$PATH" 
export PATH="/usr/local/bin:/usr/local/sbin:/usr/local/mysql/bin:$PATH"
export EDITOR='mate -w'
export LSCOLORS=gxfxcxdxbxegedabagacad


 
# Initial Display
echo "                       _                 _                  "
echo " Welcome back,        | |               | |                 "
echo "     ____   ____  ____| |  _ _   _ ____ | | _   ___  _   _  "
echo "    |    \ / _  |/ ___) | / ) | | |  _ \| || \ / _ \| | | | "
echo "    | | | ( ( | | |   | |< (| |_| | | | | |_) ) |_| | |_| | "
echo "    |_|_|_|\_||_|_|   |_| \_)\____| ||_/|____/ \___/ \__  | "
echo "                                  |_|               (____/  "
echo " "
