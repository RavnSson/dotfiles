##### ===============================
#####  ZSHRC — Umbryne Terminal (clean)
##### ===============================

##### ---- Agente SSH ----
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

##### ---- Opciones base ----
setopt histignorealldups
setopt sharehistory
setopt prompt_subst

##### ---- Historial ----
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$HOME/.zsh_history"

##### ---- Keybindings ----
bindkey -e   # estilo emacs

##### ===============================
##### Completion (moderna y limpia)
##### ===============================
autoload -Uz compinit

# Evita re-crear el dump en cada shell si no hace falta
# (mejora tiempo de inicio y reduce glitches)
if [[ ! -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh" ]]; then
  mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
fi
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"

zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%F{8}%d%f'
zstyle ':completion:*:messages'     format '%F{8}%d%f'
zstyle ':completion:*:warnings'     format '%F{1}%d%f'

# Matching flexible (mayúsculas, guiones, puntos)
zstyle ':completion:*' completer _expand _complete _correct
zstyle ':completion:*' matcher-list \
  'm:{a-z}={A-Z}' \
  'r:|[._-]=* r:|=*'

# Colores heredados de ls
if command -v dircolors >/dev/null 2>&1; then
  eval "$(dircolors -b)"
  zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
fi

# Mejor completion para kill
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

##### ===============================
##### Aliases básicos (no visuales)
##### ===============================
alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

##### ===============================
##### Flutter / Android / Web
##### ===============================
export PATH="$HOME/develop/flutter/bin:$PATH"
export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
export PATH="$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin"
export PATH="$PATH:$ANDROID_SDK_ROOT/platform-tools"
export CHROME_EXECUTABLE="$(command -v chromium 2>/dev/null || true)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

##### ===============================
##### Prompt Umbryne Terminal (manual)
##### ===============================

# Colores (truecolor). %{% %} evita que Zsh “cuente” estos bytes como caracteres.
autoload -Uz colors && colors
setopt PROMPT_SUBST

C_TXT="%{%F{#C5C8C6}%}"   # Ceniza espectral
C_ACC="%{%F{#00FF66}%}"   # Verde fósforo
C_ERR="%{%F{#D92626}%}"   # Rojo sangreal
C_RST="%{%f%k%}"

# Rama git (sin prefijo). Vacío si no estás en repo.
umbryne_git_branch() {
  local b
  b="$(command git rev-parse --abbrev-ref HEAD 2>/dev/null)" || return 0
  [[ -n "$b" && "$b" != "HEAD" ]] && print -r -- "$b"
}

# Construye la primera línea del prompt ANTES de dibujar
# Importante: se guarda $? al inicio para no perder el exit code.
umbryne_precmd() {
  local ec=$?
  local mark
  if (( ec == 0 )); then
    mark="${C_ACC}✔${C_RST}"
  else
    mark="${C_ERR}✖${C_RST}"
  fi

  local branch="$(umbryne_git_branch)"
  if [[ -n "$branch" ]]; then
    PROMPT_LINE1="${C_TXT}%~${C_RST}  ${C_ACC}${branch}${C_RST} ${mark}"
  else
    PROMPT_LINE1="${C_TXT}%~${C_RST} ${mark}"
  fi
}

# Título del terminal sin pisar precmd (usamos add-zsh-hook)
umbryne_title() {
  case "$TERM" in
    xterm*|rxvt*|screen*|tmux*)
      print -Pn "\e]0;%n@%m: %~\a"
    ;;
  esac
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd umbryne_precmd
add-zsh-hook precmd umbryne_title

# Prompt final (2 líneas)
PROMPT='${PROMPT_LINE1}
${C_ACC}❯${C_RST} '
