FROM vastai/pytorch

USER root
RUN apt-get update

#get add-apt-repository
RUN apt-get install -y software-properties-common

#install neovim
RUN add-apt-repository -y ppa:neovim-ppa/unstable
RUN apt-get update
RUN apt-get install -y neovim
RUN pip install neovim-remote pynvim

#install rust packages
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
RUN ~/.cargo/bin/cargo install bat exa ripgrep

#install zsh
RUN apt-get install -y  git-core gcc make autoconf yodl libncursesw5-dev texinfo man-db
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

#python installs
RUN apt-get update
RUN apt-get install -y python3.5-dev
RUN curl https://bootstrap.pypa.io/ez_setup.py -o - | python3.5
RUN python3.5 -m easy_install pip==10.0.1
RUN pip3.5 install tensorflow
RUN pip install dropbox dill tensorboardX albumentations
RUN apt-get install -y unzip python-qt4 libglib2.0-0 pkg-config

#ctags
RUN git clone https://github.com/universal-ctags/ctags.git
RUN cd ctags && ./autogen.sh && ./configure && make && make install

#install dotfiles
RUN rm -f ~/.profile
RUN git clone https://github.com/rgreenblatt/dotfiles
RUN cd dotfiles && ./install.sh devbox -c

#nvim plug sync
RUN curl -L -o ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
RUN nvim +PlugInstall +qa
RUN /bin/zsh -c "source ~/.profile && bat cache --build"
RUN cd ~/.fzf && ./install --all
ENV SHELL=/bin/zsh 

RUN rm -rf ctags setuptools* zsh 

CMD [ "/usr/bin/nvim", "+te"]
