#!/bin/bash

# Habilitar modo estrito de execução
set -euo pipefail

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Função para log
log() {
    echo -e "${GREEN}=> ⏳ $1${NC}"
}

log_error() {
    echo -e "${RED}ERROR: $1${NC}" >&2
}

log_warning() {
    echo -e "${YELLOW}WARNING: $1${NC}"
}

# Função para verificar se comando foi bem sucedido
check_command() {
    if ! "$@"; then
        log_error "Comando falhou: $*"
        exit 1
    fi
}

# Função para fazer backup de arquivo
backup_file() {
    local file=$1
    if [ -f "$file" ]; then
        cp "$file" "${file}.backup-$(date +%Y%m%d%H%M%S)"
    fi
}

# Verificar se está rodando como root
if [ "$(id -u)" = "0" ]; then
    log_error "Este script não deve ser executado como root"
    exit 1
fi

# Verificar se é Debian
if ! grep -q "Debian" /etc/os-release; then
    log_warning "Este script foi testado apenas no Debian"
fi

# Atualizar sistema
log "Configurando comportamento geral do sistema"
log "--> ⬇ Atualizando Sistema"
check_command sudo apt update
check_command sudo apt upgrade -y
check_command sudo apt install git curl wget vim fonts-firacode -y

# Instalar ZSH
log "Instalando ZSH"
check_command sudo apt install zsh -y
check_command sudo chsh -s $(which zsh) $USER

# Instalar Oh My Zsh e plugins
log "Instalando Powerlevel10k"
log "--> Instalando Oh My Zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

log "--> Instalando plugins do Zsh"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Array de plugins para instalar
declare -A plugins=(
    ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions"
    ["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting.git"
    ["fast-syntax-highlighting"]="https://github.com/zdharma-continuum/fast-syntax-highlighting.git"
    ["zsh-autocomplete"]="https://github.com/marlonrichert/zsh-autocomplete.git"
)

for plugin in "${!plugins[@]}"; do
    plugin_dir="${ZSH_CUSTOM}/plugins/${plugin}"
    if [ ! -d "$plugin_dir" ]; then
        check_command git clone "${plugins[$plugin]}" "$plugin_dir"
    else
        log_warning "Plugin $plugin já existe, pulando..."
    fi
done

log "--> Copiando configurações do Oh My Zsh"
backup_file ~/.zshrc
check_command cp .zshrc-slim ~/.zshrc

log "--> Instalando tema p10k"
p10k_dir="${ZSH_CUSTOM}/themes/powerlevel10k"
if [ ! -d "$p10k_dir" ]; then
    check_command git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
else
    log_warning "Powerlevel10k já existe, pulando..."
fi

backup_file ~/.p10k.zsh
check_command cp .p10k.zsh-slim ~/.p10k.zsh

log "Instalação concluída com sucesso!"
echo "~ The End ~"

# Lembrar usuário de fazer source do .zshrc
log_warning "Lembre-se de executar 'source ~/.zshrc' ou reiniciar seu terminal para aplicar todas as alterações" 