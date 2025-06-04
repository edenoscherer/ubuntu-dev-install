#!/bin/bash

# Habilitar modo estrito de execução
set -euo pipefail

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Versões de software
NVM_VERSION="v0.40.1"

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
check_command sudo apt install git curl wget vim fonts-firacode build-essential zip unzip -y

# Configurar git
log "Configurando Git"
check_command git config --global user.name "Edeno Scherer"
check_command git config --global user.email edenoscherer@gmail.com
check_command git config --global init.defaultBranch main
# Usar credencial manager mais seguro se disponível
if command -v git-credential-libsecret > /dev/null; then
    git config --global credential.helper libsecret
else
    log_warning "git-credential-libsecret não encontrado, usando store"
    git config --global credential.helper 'store'
fi

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
check_command cp .zshrc ~/.zshrc

log "--> Instalando tema p10k"
p10k_dir="${ZSH_CUSTOM}/themes/powerlevel10k"
if [ ! -d "$p10k_dir" ]; then
    check_command git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
else
    log_warning "Powerlevel10k já existe, pulando..."
fi

backup_file ~/.p10k.zsh
check_command cp .p10k.zsh ~/.p10k.zsh

# Instalar NVM
log "Instalando NVM"
curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
check_command nvm install --lts

# Instalar AWS CLI
log "Instalando AWS CLI"
mkdir -p "$HOME/Downloads"
cd "$HOME/Downloads" || exit 1
check_command curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
check_command unzip -o awscliv2.zip
check_command sudo ./aws/install --update

# Instalar Docker
log "Instalando Docker"
check_command sudo apt install -y ca-certificates curl
check_command sudo install -m 0755 -d /etc/apt/keyrings
check_command sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
check_command sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

check_command sudo apt update
check_command sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
check_command sudo systemctl enable /usr/lib/systemd/system/docker.service

# Adicionar usuário ao grupo docker se ainda não estiver
if ! groups "$USER" | grep -q "\bdocker\b"; then
    sudo groupadd -f docker
    sudo usermod -aG docker "$USER"
    log_warning "Você precisa fazer logout e login novamente para usar o Docker sem sudo"
fi

log "Instalação concluída com sucesso!"
echo "~ The End ~"

# Lembrar usuário de fazer source do .zshrc
log_warning "Lembre-se de executar 'source ~/.zshrc' ou reiniciar seu terminal para aplicar todas as alterações" 