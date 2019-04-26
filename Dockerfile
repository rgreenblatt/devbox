FROM ubuntu:18.04

USER root

RUN mkdir /install
WORKDIR /install

RUN apt-get update && apt-get install -y \
      software-properties-common \
      python3-dev \
      git \
      build-essential \
      cmake \
      autoconf \
      yodl \
      libncursesw5-dev \
      texinfo \
      man-db \
      gperf \
      luajit \
      luarocks \
      libuv1-dev \
      libluajit-5.1-dev \
      libunibilium-dev \
      libmsgpack-dev \
      libtermkey-dev \
      libvterm-dev \
      gettext

RUN git clone --single-branch --branch floatblend \
      https://github.com/bfredl/neovim.git && cd neovim && \
      make CMAKE_BUILD_TYPE=RelWithDebInfo && make install

#install rust packages
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
RUN ~/.cargo/bin/cargo install \
      bat \
      exa \
      ripgrep

#install zsh
RUN apt-get install -y  
RUN git clone https://github.com/zsh-users/zsh
RUN cd zsh && ./Util/preconfig && ./configure --prefix=/usr \
    --mandir=/usr/share/man \
    --bindir=/bin \
    --infodir=/usr/share/info \
    --enable-maildir-support \
    --enable-max-jobtable-size=256 \
    --enable-etcdir=/etc/zsh \
    --enable-function-subdirs \
    --enable-site-fndir=/usr/local/share/zsh/site-functions \
    --enable-fndir=/usr/share/zsh/functions \
    --with-tcsetpgrp \
    --with-term-lib="ncursesw" \
    --enable-cap \
    --enable-pcre \
    --enable-readnullcmd=pager \
    --enable-custom-patchlevel=Debian \
    LDFLAGS="-Wl,--as-needed -g" && \
    make && make check && make install
RUN chsh -s /bin/zsh

#ctags
RUN git clone https://github.com/universal-ctags/ctags.git
RUN cd ctags && ./autogen.sh && ./configure && make && make install

#install dotfiles
RUN echo ""
RUN git clone https://github.com/rgreenblatt/dotfiles
RUN cd dotfiles && ./install.sh devbox -c

#nvim plug sync
RUN curl -L -o ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
RUN nvim +PlugInstall +qa
RUN cd ~/.fzf && ./install --all
ENV SHELL=/bin/zsh 
RUN mkdir ~/.cache
RUN /bin/zsh -c "source ~/.profile && bat cache --build"

RUN rm -rf ctags setuptools* zsh neovim

CMD bash -c "source /root/.profile && /usr/bin/nvim +te"
