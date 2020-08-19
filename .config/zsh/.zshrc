# Path to your oh-my-zsh installation.
export ZSH="/home/apiz19/.config/zsh"
ZSH_THEME="spaceship"
# Uncomment the following line to disable bi-weekly auto-update checks.
 DISABLE_AUTO_UPDATE="true"
# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"
# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Would you like to use another custom folder than $ZSH/custom?
 ZSH_CUSTOM=$ZDOTDIR/custom/

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git extract dnote fd dotbare archlinux zsh-syntax-highlighting colored-man-pages)

# Load aliases and shortcuts if existent.
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shortcutrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shortcutrc"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/aliasrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/aliasrc"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/zshnameddirrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/zshnameddirrc"
# [ -f "${XDG_CONFIG_HOME:-$HOME/.config}/functionrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/functionrc"

source $ZSH/oh-my-zsh.sh

# shell: zsh settings
function reshell () {
    exec zsh -l
}

# fzf *.pdf search
function p () {
    ag -U -g ".pdf$" \
    | fast-p \
    | fzf --read0 --reverse -e -d $'\t'  \
        --preview-window down:80% --preview '
            v=$(echo {q} | tr " " "|");
            echo -e {1}"\n"{2} | grep -E "^|$v" -i --color=always;
        ' \
    | cut -z -f 1 -d $'\t' | tr -d '\n' | xargs -r --null $open
}

# fuzzy search | fzf
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh

# completion
autoload -U compinit && compinit
_dotbare_completion_cmd
