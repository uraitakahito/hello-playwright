# ## Features of this Dockerfile
#
# - Various customizations
# - Not based on devcontainer; use by attaching VSCode to the container
# - Assumes host OS is Mac
#
# ## Preparation
#
# ### Starting the Playwright Server
#
# Start the Playwright server on your Mac beforehand.
#
#   docker run --add-host=playwright:host-gateway -p 3000:3000 --rm --init -it --workdir /home/pwuser --user pwuser mcr.microsoft.com/playwright:v1.57.0-noble /bin/sh -c "npx -y playwright@1.57.0 run-server --port 3000 --host 0.0.0.0"
#
# ### SSH Agent
#
# Uses ssh-agent. After a restart, if you have not yet initiated an SSH login from your Mac, run the following command on the Mac.
#
#   ssh-add --apple-use-keychain ~/.ssh/id_ed25519
#
# For more details about ssh-agent, see:
#
#   https://github.com/uraitakahito/hello-docker/blob/c942ab43712dde4e69c66654eac52d559b41cc49/README.md
#
# ### Download the files required to build the Docker container
#
#   curl -L -O https://raw.githubusercontent.com/uraitakahito/hello-javascript/refs/heads/main/docker-entrypoint.sh
#   chmod 755 docker-entrypoint.sh
#
# ## From Docker build to login
#
# Build the Docker image:
#
#   PROJECT=$(basename `pwd`) && docker image build -t $PROJECT-image . --build-arg user_id=`id -u` --build-arg group_id=`id -g` --build-arg TZ=Asia/Tokyo
#
# Create a volume to persist the command history executed inside the Docker container.
# It is stored in the volume because the dotfiles configuration redirects the shell history there.
#   https://github.com/uraitakahito/dotfiles/blob/b80664a2735b0442ead639a9d38cdbe040b81ab0/zsh/myzshrc#L298-L305
#
#   docker volume create $PROJECT-zsh-history
#
# Start the Docker container:
#
#   docker container run --add-host=playwright:host-gateway -d --rm --init -v $SSH_AUTH_SOCK:/ssh-agent -e SSH_AUTH_SOCK=/ssh-agent --mount type=bind,src=`pwd`,dst=/app --mount type=volume,source=$PROJECT-zsh-history,target=/zsh-volume --name $PROJECT-container $PROJECT-image
#
# Log in to Docker:
#
#   fdshell /bin/zsh
#
# About fdshell:
#   https://github.com/uraitakahito/dotfiles/blob/37c4142038c658c468ade085cbc8883ba0ce1cc3/zsh/myzshrc#L93-L101
#
# Only for the first startup, change the owner of the command history folder:
#
#   sudo chown -R $(id -u):$(id -g) /zsh-volume
#
# ## Launch Claude
#
#   claude --dangerously-skip-permissions
#
# ## Connect from Visual Studio Code
#
# 1. Open **Command Palette (Shift + Command + p)**
# 2. Select **Dev Containers: Attach to Running Container**
# 3. Open the `/app` directory
#
# For details:
#   https://code.visualstudio.com/docs/devcontainers/attach-container#_attach-to-a-docker-container
#
# Run the following commands inside the Docker containers as needed:
#
# ```sh
# npm ci
# npx eslint .
# ```
#

# Debian 12.12
FROM debian:bookworm-20251117

ARG user_name=developer
ARG user_id
ARG group_id
ARG dotfiles_repository="https://github.com/uraitakahito/dotfiles.git"
ARG features_repository="https://github.com/uraitakahito/features.git"
ARG extra_utils_repository="https://github.com/uraitakahito/extra-utils.git"
# Refer to the following URL for Node.js versions:
#   https://nodejs.org/en/about/previous-releases
ARG node_version="24.4.0"

#
# Git
#
RUN apt-get update -qq && \
  apt-get install -y -qq --no-install-recommends \
    ca-certificates \
    git && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

#
# clone features
#
RUN cd /usr/src && \
  git clone --depth 1 ${features_repository}

#
# Add user and install common utils.
#
RUN USERNAME=${user_name} \
    USERUID=${user_id} \
    USERGID=${group_id} \
    CONFIGUREZSHASDEFAULTSHELL=true \
    UPGRADEPACKAGES=false \
      /usr/src/features/src/common-utils/install.sh

#
# Install extra utils.
#
RUN cd /usr/src && \
  git clone --depth 1 ${extra_utils_repository} && \
  ADDEZA=true \
  UPGRADEPACKAGES=false \
    /usr/src/extra-utils/utils/install.sh

#
# Install Node
#   https://github.com/uraitakahito/features/blob/develop/src/node/install.sh
#
RUN INSTALLYARNUSINGAPT=false \
    NVMVERSION="latest" \
    PNPM_VERSION="none" \
    USERNAME=${user_name} \
    VERSION=${node_version} \
      /usr/src/features/src/node/install.sh

COPY docker-entrypoint.sh /usr/local/bin/

USER ${user_name}

#
# dotfiles
#
RUN cd /home/${user_name} && \
  git clone --depth 1 ${dotfiles_repository} && \
  dotfiles/install.sh

#
# Claude Code
#
# Discussion about using nvm during Docker container build:
#   https://stackoverflow.com/questions/25899912/how-to-install-nvm-in-docker
ARG TZ
ENV TZ="$TZ"
ENV NVM_DIR=/usr/local/share/nvm
RUN bash -c "source $NVM_DIR/nvm.sh && \
             nvm use ${node_version} && \
             npm install -g @anthropic-ai/claude-code"

#
# WARNING: Do NOT expose port 3000 here.
#
# When VS Code's "Attach to Running Container" feature connects to this container,
# it automatically detects exposed ports and sets up port forwarding from the Mac's
# localhost to the container. This is called "Auto Forward Ports" feature.
#
# In projects where a server runs on the Mac host (e.g., Playwright server) and
# the container connects to it via `--add-host=<hostname>:host-gateway`, exposing
# the same port here causes a conflict.
#
# If this port is exposed, VS Code will forward Mac's localhost:<port> to the
# container's localhost:<port>, which intercepts connections intended for the
# Mac host server. This causes WebSocket or HTTP connections to hang indefinitely.
#
# Symptoms:
#   - TCP connection succeeds (handshake completes)
#   - But no data is received and the connection eventually times out
#   - Works fine before VS Code attaches, fails after attaching
#
# To disable VS Code's auto port forwarding, you can also add this to settings.json:
#   "remote.autoForwardPorts": false
# Or ignore specific ports:
#   "remote.portsAttributes": { "3000": { "onAutoForward": "ignore" } }
#
# EXPOSE 3000
#

WORKDIR /app
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["tail", "-F", "/dev/null"]
