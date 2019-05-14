FROM nvidia/cuda:10.1-devel-ubuntu18.04

USER root

#install directory {{{1
RUN mkdir /install
WORKDIR /install

#general installs {{{1
RUN apt-get update && apt-get install -y \
      software-properties-common \
      python3-dev \
      python3-pip \
      git \
      build-essential \
      cmake \
      unzip \
      man-db
      
#zsh {{{1
RUN apt-get update && apt-get install -y zsh
ENV SHELL=/bin/zsh 

#install neovim {{{1
RUN apt-get update && apt-get install -y \
      gperf \
      luajit \
      luarocks \
      libuv1-dev \
      libluajit-5.1-dev \
      libunibilium-dev \
      libmsgpack-dev \
      libtermkey-dev \
      libvterm-dev \
      m4 \
      automake \
      gettext && \
      git clone --single-branch --branch floatblend \
      https://github.com/bfredl/neovim.git && cd neovim && \
      make CMAKE_BUILD_TYPE=RelWithDebInfo && make install && \
      pip3 install \
      neovim-remote \
      pynvim

#install rust packages {{{1
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
      ~/.cargo/bin/cargo install \
      bat \
      exa \
      ripgrep \
      fd-find \
      sd

#ctags {{{1
RUN git clone https://github.com/universal-ctags/ctags.git && cd ctags && \
      ./autogen.sh && ./configure && make && make install
      

#install general python packages {{{1
RUN pip3 install thefuck

#fix locale issues??? {{{1
RUN apt-get clean && apt-get update && apt-get install -y locales && \
      locale-gen en_US.UTF-8 && update-locale LC_ALL=en_US.UTF-8 \
      LANG=en_US.UTF-8

#install dotfiles {{{1
RUN git clone https://github.com/rgreenblatt/dotfiles && \
      cd dotfiles && ./install.sh devbox -c && ./autoinstall.sh

#clean up {{{1
WORKDIR /root/
RUN rm -rf /install
#}}}

# vim: set fdm=marker:
