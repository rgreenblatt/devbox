FROM nvidia/cuda:10.1-devel-ubuntu18.04

USER root

#install directory {{{1
RUN mkdir /install
WORKDIR /install

#general installs {{{1
RUN apt-get update && apt-get install -y \
      build-essential \
      cmake \
      curl \
      git \
      man-db \
      python3-dev \
      python3-pip \
      software-properties-common \
      unzip
      
#zsh {{{1
RUN apt-get update && apt-get install -y zsh
ENV SHELL=/bin/zsh 

#install neovim {{{1
RUN add-apt-repository ppa:neovim-ppa/unstable && \
      apt-get update && apt-get install -y neovim && \
      pip3 install neovim-remote pynvim

#install rust packages {{{1
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
      ~/.cargo/bin/cargo install \
      bat \
      exa \
      ripgrep \
      fd-find \
      sd

#ctags {{{1
RUN apt-get update && apt-get install -y \
      autoconf \
      pkg-config && \
      git clone https://github.com/universal-ctags/ctags.git && cd ctags && \
      ./autogen.sh && ./configure && make && make install
      

#install general python packages {{{1
RUN pip3 install cmakelint bpython

#fix locale issues??? {{{1
RUN apt-get clean && apt-get update && apt-get install -y locales && \
      locale-gen en_US.UTF-8 && update-locale LC_ALL=en_US.UTF-8 \
      LANG=en_US.UTF-8

#install dotfiles {{{1
RUN cd ~ && git clone https://github.com/rgreenblatt/dotfiles && \
      cd dotfiles && ./install.sh devbox -c && ./autoinstall.sh

#clean up {{{1
WORKDIR /root/
RUN rm -rf /install
#}}}

# vim: set fdm=marker:
