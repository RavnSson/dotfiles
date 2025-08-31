# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
alias godot='flatpak run org.godotengine.Godot'

# --- Prompt estilo CodexSyn (reactivo) ---
csyn_git_branch() { git branch --show-current 2>/dev/null; }

csyn_set_prompt() {
  local last_status=$?   # <-- capturamos aquí ANTES de nada

  local grn="\[\e[1;32m\]" # verde
  local red="\[\e[1;31m\]" # rojo
  local wht="\[\e[0;37m\]" # gris/blanco tenue
  local mag="\[\e[1;35m\]" # magenta glitch (rama git)
  local rst="\[\e[0m\]"

  local base sep_color
  if [ $last_status -eq 0 ]; then
    base=$grn
    sep_color="\e[0;32m"   # verde
  else
    base=$red
    sep_color="\e[0;31m"   # rojo
  fi

  # separador dinámico (según estado)
  printf "${sep_color}===============\e[0m\n"

  # rama git si existe
  local branch="$(csyn_git_branch)"
  if [ -n "$branch" ]; then
    PS1="${base}CodexSyn⚝${wht}\w ${mag}(${branch})${base}>\ ${rst}"
  else
    PS1="${base}CodexSyn⚝${wht}\w${base}>\ ${rst}"
  fi
}

PROMPT_COMMAND=csyn_set_prompt

# --- Función efecto máquina de escribir con soporte de color ---
typeprint () {
  local text="$1"
  local delay="${2:-0.03}" # velocidad por caracter
  local color="$3"         # color ANSI opcional, ej: "\e[1;35m"
  
  printf "$color"
  while IFS= read -r -n1 char; do
    printf "%s" "$char"
    sleep "$delay"
  done <<< "$text"
  printf "\e[0m\n" # reset al final
}

# --- Figlet + typewriter (línea por línea, sin deformar) ---
figlet_typewriter () {
  local text="$1"
  local delay="${2:-0.1}"       # 0.1 seg por línea (ajusta a tu gusto)
  local color="${3:-\e[1;32m}"  # verde CRT por defecto

  if ! command -v figlet >/dev/null 2>&1; then
    # Fallback si no está figlet
    typeprint "$text" 0.05 "$color"
    return
  fi

  # Genera el ASCII con figlet
  local output
  output="$(figlet -f standard -- "$text")" || {
    typeprint "$text" 0.05 "$color"
    return
  }

  # Imprime línea por línea con retraso
  printf "%b" "$color"
  while IFS= read -r line; do
    echo "$line"
    sleep "$delay"
  done <<< "$output"
  printf "\e[0m"
}

# --- Intro minimal CodexSyn ⚝ ---
intro_codexsyn() {
  # Colores
  local MAG="\e[1;35m"  # magenta glitch
  local GRN="\e[1;32m"  # verde CRT
  local RST="\e[0m"

  # 1) Mensaje inicial
  typeprint "Present day..." 0.05 "$MAG"
  sleep 1
  typeprint "Present time..." 0.05 "$MAG"
  sleep 1

  # 2) Banner (figlet + opcional lolcat)
  figlet_typewriter "CodexSyn" 0.05 "$GRN"
  sleep 1

   # 3) Fastfetch / Neofetch (si hay)
  if command -v fastfetch >/dev/null 2>&1; then
    fastfetch 2>/dev/null
  elif command -v neofetch >/dev/null 2>&1; then
    neofetch 2>/dev/null
  fi

  # 4) Limpiar
  sleep 1
  clear

  # 5) Frase según el día (queda visible)
  # 1=Lun ... 7=Dom
  case "$(date +%u)" in
    1) day_msg="No importa a dónde vayas, todos estamos conectados." ;;
    2) day_msg="Las personas solo tienen sustancia dentro de los recuerdos de los demás." ;;
    3) day_msg="Si no eres recordado, nunca exististe." ;;
    4) day_msg="El Wired podría ser pensamiento." ;;
    5) day_msg="Solo existo dentro de aquellos que son conscientes de mi existencia." ;;
    6) day_msg="¿Quién necesita recuerdos? Son solo una carga." ;;
    7) day_msg="La única diferencia entre el Wired y el mundo real es la cantidad de información." ;;
  esac
  typeprint "$day_msg" 0.05 "\e[1;35m"
}
# Ejecutar la intro al abrir la terminal
intro_codexsyn
