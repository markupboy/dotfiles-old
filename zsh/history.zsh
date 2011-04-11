# enable and configure the history
setopt APPEND_HISTORY			# append the history file (!important for using multiple zsh sessions)
setopt SHARE_HISTORY			# use commands history files used by different zsh sessions
setopt HIST_IGNORE_DUPS		# ignore adjacent duplicate commands

HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.history
DIRSTACKSIZE=20