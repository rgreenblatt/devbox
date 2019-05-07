FROM nvidia/cuda:10.1-devel-ubuntu18.04

USER root

RUN mkdir /install
WORKDIR /install

RUN apt-get update && apt-get install -y \
      software-properties-common \
      python3-dev \
      python3-pip \
      git \
      build-essential \
      cmake \
      texinfo \
      man-db \
      luajit \
      luarocks \
      libuv1-dev \
      libluajit-5.1-dev \
      libunibilium-dev \
      libmsgpack-dev \
      libtermkey-dev \
      libvterm-dev \
      gettext \
      m4 \
      automake \
      zsh \
      unzip \
      pkg-config \
      libsm6 \
      libxext6 \
      libxrender-dev


RUN chsh -s /bin/zsh

RUN git clone --single-branch --branch floatblend \
      https://github.com/bfredl/neovim.git && cd neovim && \
      make CMAKE_BUILD_TYPE=RelWithDebInfo && make install

#install rust packages
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
RUN ~/.cargo/bin/cargo install \
      bat \
      exa \
      ripgrep \
      fd-find \
      sd

#ctags
RUN git clone https://github.com/universal-ctags/ctags.git
RUN cd ctags && ./autogen.sh && ./configure && make && make install

#install dotfiles
RUN git clone https://github.com/rgreenblatt/dotfiles
RUN cd dotfiles && ./install.sh devbox -c

RUN pip3 install \
      neovim-remote \
      pynvim \
      thefuck

#nvim plug sync
RUN curl -L -o ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
# RUN curl -L  \
#   https://raw.githubusercontent.com/zplug/installer/master/installer.zsh > \
#   installer.zsh \
#   && chmod +x installer.zsh && ./installer.zsh
RUN nvim +PlugInstall +qa
RUN cd ~/.fzf && ./install --all
# RUN zsh -c "source ~/.zshrc && zplug install"
RUN cd ~/.local/share/nvim/plugged/sneak-quick-scope/src/ && ./build.sh && cp sneak_quick_scope /usr/local/bin/
ENV SHELL=/bin/zsh 
RUN mkdir -p ~/.cache
RUN /bin/zsh -c "source ~/.profile && bat cache --build"

RUN rm -rf ctags setuptools* zsh neovim

CMD bash -c "source /root/.profile && nvim +te"
