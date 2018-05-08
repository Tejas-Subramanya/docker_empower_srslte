## build : docker build -t srsenb .
## run :   docker run --net=host --rm --privileged -v /dev/bus/usb:/dev/bus/usb -it srsenb

FROM ubuntu:14.04
MAINTAINER Tejas Subramanya <tejas.sln89@gmail.com>
ENV DEBIAN_FRONTEND noninteractive
#RUN apt-get update
#RUN apt-get -yq dist-upgrade 

# Dependencies for the UHD driver for the USRP hardware
RUN apt-get update && \
    apt-get -yq dist-upgrade && \
    apt-get -yq install autoconf build-essential libusb-1.0-0-dev cmake wget pkg-config libboost-all-dev python-dev python-cheetah git python-software-properties

# Dependencies for UHD image downloader script
RUN apt-get -yq install python-mako python-requests 

# Fetching the uhd 3.010.001 driver for our USRP SDR card 
RUN wget http://files.ettus.com/binaries/uhd/uhd_003.010.001.001-release/uhd-3.10.1.1.tar.gz && tar xvzf uhd-3.10.1.1.tar.gz && cd UHD_3.10.1.1_release && mkdir build && cd build && cmake ../ && make && make install && ldconfig && python /usr/local/lib/uhd/utils/uhd_images_downloader.py

# Dependencies for SRSeNB
RUN apt-get -yq --no-install-recommends --assume-yes install libfftw3-dev libpolarssl5 libpolarssl-dev libpolarssl-runtime libboost-all-dev libconfig++-dev libsctp-dev 

# Fetching the latest repository and Building the srslte eNB for USRP
RUN git clone https://github.com/5g-empower/empower-enb-proto.git && cd empower-enb-proto && make && make install
RUN git clone https://github.com/5g-empower/empower-enb-agent.git && cd empower-enb-agent && make && make install
RUN git clone https://github.com/5g-empower/empower-srsLTE.git && cd empower-srsLTE && git checkout agent && mkdir build && chmod 755 build && cd build && cmake ../ && make && make install && ldconfig

# Add a sample configuration file
ADD enb.conf /empower-srsLTE/enb.conf
ADD drb.conf /empower-srsLTE/drb.conf
ADD rr.conf /empower-srsLTE/rr.conf
ADD sib.conf /empower-srsLTE/sib.conf

# Run directly the eNodeB code
#ENTRYPOINT ./empower-srsLTE/build/srsenb/src/srsenb /srsLTE/enb.conf
