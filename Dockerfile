FROM centos:7 AS build_stage

MAINTAINER brainsam@yandex.ru
MAINTAINER thinker0@gmail.com

WORKDIR /
RUN yum -y groupinstall 'Development Tools'
RUN yum -y install git python python-pip python-docutils build-base automake libtool m4 autoconf libevent-devel openssl-devel c-ares-devel python2
RUN git clone https://github.com/pgbouncer/pgbouncer.git src

WORKDIR /bin
#RUN ln -s ../usr/bin/rst2man.py rst2man

WORKDIR /src
RUN mkdir /pgbouncer
RUN git submodule init
RUN git submodule update
RUN ./autogen.sh
RUN	./configure --prefix=/pgbouncer --with-libevent=/usr/lib
RUN make
RUN make install
RUN ls -R /pgbouncer

FROM centos:7
RUN yum -y install libevent openssl c-ares python python2
WORKDIR /
COPY --from=build_stage /pgbouncer /pgbouncer
ADD entrypoint.sh ./
ENTRYPOINT ["./entrypoint.sh"]
