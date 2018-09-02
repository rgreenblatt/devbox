FROM ubuntu:16.04
#No wpilib toolchain for 18.04 :(

MAINTAINER Ryan Greenblatt <greenblattryan@gmail.com>

USER root

RUN apt-get update
RUN apt-get install -y software-properties-common
RUN apt-get install -y openjdk-8-jdk-headless wget unzip vim  
RUN apt-get install -y g++ git cmake cmake-extras
RUN apt-get install -y sudo

WORKDIR /TEMP

#Installs googletest
RUN wget https://github.com/google/googletest/archive/release-1.8.0.tar.gz
RUN tar -xzvf release-1.8.0.tar.gz
WORKDIR /TEMP/googletest-release-1.8.0/googletest
RUN mkdir mybuild
WORKDIR /TEMP/googletest-release-1.8.0/googletest/mybuild
RUN cmake -G"Unix Makefiles" ..
RUN make

RUN cp lib*.a /usr/local/lib
RUN cp -r ../include/gtest /usr/local/include

RUN useradd -m builder && echo "builder:builder" | chpasswd && adduser builder sudo

RUN DEBIAN_FRONTEND=interactive

USER builder
WORKDIR /home/builder
ENV HOME /home/builder
