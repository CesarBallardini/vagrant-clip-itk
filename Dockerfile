FROM debian:stretch AS builder
MAINTAINER Cesar Ballardini <cesar.ballardini@gmail.com>
LABEL description="Build container - clip-itk"

## Instrucciones elementales
#time docker build -t cesarballardini/clip-itk:latest .
#docker run -it --name devtest --mount type=bind,source="$(pwd)",target=/root/app cesarballardini/clip-itk:latest /bin/bash


ENV DEBIAN_FRONTEND=noninteractive
ENV APT_LISTCHANGES_FRONTEND=none
ENV APT_OPTIONS=' -y --allow-downgrades --allow-remove-essential --allow-change-held-packages -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold '

########################### Requisitos de clip
RUN echo 'deb http://deb.debian.org/debian stretch-backports main contrib non-free' > /etc/apt/sources.list.d/backports.list
RUN { \
  echo 'deb http://deb.debian.org/debian stretch main contrib non-free' ; \
   } > /etc/apt/sources.list

RUN echo "Acquire::Check-Valid-Until false;" | tee --append /etc/apt/apt.conf

RUN apt-get update -y -qq \
   && apt-get --purge remove apt-listchanges -y > /dev/null 2>&1 \
   && apt-get update -y -qq > /dev/null 2>&1 \
   && dpkg-reconfigure --frontend=noninteractive libc6 > /dev/null 2>&1 \
   && apt-get install linux-image-amd64 ${APT_OPTIONS}  || true \
   && apt-get upgrade ${APT_OPTIONS} > /dev/null 2>&1 \
   && apt-get dist-upgrade ${APT_OPTIONS} > /dev/null 2>&1 \
   && apt-get autoremove -y > /dev/null 2>&1 \
   && apt-get autoclean -y > /dev/null 2>&1 \
   && apt-get clean > /dev/null 2>&1

RUN apt-get install ${APT_OPTIONS} git 

RUN apt-get install ${APT_OPTIONS} \
          lsb-release \
          flex bison \
          libc6-dev libc6-i386 libgpm-dev libncurses5-dev libpth-dev

RUN apt-get install ${APT_OPTIONS} -t stretch-backports \
          gcc-multilib build-essential debhelper libmariadbclient-dev

########################### Clona repositorio'
WORKDIR /root/
RUN git --version && lsb_release -a 
#RUN git clone https://github.com/CesarBallardini/clip-it
RUN git clone  https://github.com/CesarBallardini/clip-itk.git
RUN cd clip-itk/ && git checkout fix-make-deb && make system && make tgz
RUN ls -l /root/clip_distrib/1.2.0-0/

#
# ------------------------------------------------------------------------
#

FROM debian:stretch as runtime
MAINTAINER Cesar Ballardini <cesar.ballardini@gmail.com>
LABEL description="Run container - clip-itk"

ENV DEBIAN_FRONTEND=noninteractive
ENV APT_LISTCHANGES_FRONTEND=none
ENV APT_OPTIONS=' -y --allow-downgrades --allow-remove-essential --allow-change-held-packages -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold '
ENV CLIPROOT=/usr/local/clip
ENV LOCALEDIRS="$CLIPROOT/locale.pot $CLIPROOT/locale.po $CLIPROOT/locale.mo"
ENV DISTRIB_DIR=/root/clip_distrib/1.2.0-0/tar-gz-Linux-x86_64-glibc2.24
ENV LANG=en_EN.CP437

RUN mkdir /root/app
WORKDIR /root/app
COPY --from=builder ${DISTRIB_DIR} .

RUN groupadd clip ; mkdir -p $LOCALEDIRS ; chgrp -R clip $LOCALEDIRS ; chmod -R g+w $LOCALEDIRS

########################### Requisitos de clip
RUN echo 'deb http://deb.debian.org/debian stretch-backports main contrib non-free' > /etc/apt/sources.list.d/backports.list
RUN { \
  echo 'deb http://deb.debian.org/debian stretch main contrib non-free' ; \
   } > /etc/apt/sources.list

RUN echo "Acquire::Check-Valid-Until false;" | tee --append /etc/apt/apt.conf

RUN apt-get update -y -qq \
   && apt-get --purge remove apt-listchanges -y > /dev/null 2>&1 \
   && apt-get update -y -qq > /dev/null 2>&1 \
   && dpkg-reconfigure --frontend=noninteractive libc6 > /dev/null 2>&1 \
   && apt-get install linux-image-amd64 ${APT_OPTIONS}  || true \
   && apt-get upgrade ${APT_OPTIONS} > /dev/null 2>&1 \
   && apt-get dist-upgrade ${APT_OPTIONS} > /dev/null 2>&1 \
   && apt-get autoremove -y > /dev/null 2>&1 \
   && apt-get autoclean -y > /dev/null 2>&1 \
   && apt-get clean > /dev/null 2>&1

# requisitos para compilar .prg con clip'
RUN apt-get install ${APT_OPTIONS} make gcc-multilib libc6-i386 build-essential \
                   libc6-dev libgpm-dev libncurses5-dev libpth-dev libmariadbclient-dev

RUN ls -l /root/app/

RUN tar xzf /root/app/clip-com_1.2.0-0.tar.gz        -C / && \
    tar xzf /root/app/clip-dev_1.2.0-0.tar.gz        -C / && \
    tar xzf /root/app/clip-gzip_1.2.0-0.tar.gz       -C / && \
    tar xzf /root/app/clip-lib_1.2.0-0.tar.gz        -C / && \
    tar xzf /root/app/clip-oasis_1.2.0-0.tar.gz      -C / && \
    tar xzf /root/app/clip-postscript_1.2.0-0.tar.gz -C / && \
    tar xzf /root/app/clip-prg_1.2.0-0.tar.gz        -C / && \
    tar xzf /root/app/clip-r2d2_1.2.0-0.tar.gz       -C / && \
    tar xzf /root/app/clip-rtf_1.2.0-0.tar.gz        -C / && \
    tar xzf /root/app/clip-xml_1.2.0-0.tar.gz        -C /

RUN rm -f /root/app/* ; echo "/usr/local/clip/lib" | tee  /etc/ld.so.conf.d/clip.conf ; ldconfig ; clip -V
CMD ["/bin/bash"]  



