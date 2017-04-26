FROM debian:8
MAINTAINER Tom Clegg <tom@curoverse.com>

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get -y dist-upgrade && \
    apt-get install -y --no-install-recommends build-essential ca-certificates curl daemon git libmysqlclient-dev libreadline-dev libssl-dev libxslt1-dev lsof mysql-server sudo && \
    apt-get clean

ADD 90-tapestry-sudoers /etc/sudoers.d/
RUN chmod 0440 /etc/sudoers.d/90-tapestry-sudoers

RUN useradd tapestry && \
    mkdir /home/tapestry && \
    chown tapestry:tapestry /home/tapestry
USER tapestry
WORKDIR /home/tapestry
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
RUN curl -sSL https://get.rvm.io | bash -s stable && \
    bash --login -ec ' \
    rvm autolibs disable; \
    rvm install ree; \
    rvm use ree; \
    gem install bundler'
WORKDIR /home/tapestry/tapestry
