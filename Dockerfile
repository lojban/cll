FROM rlpowell/fedora_base

# Specifically needed packages, with versions where the package is
# important.
RUN dnf -y install xmlto-0.0.28 ruby-devel libxml2-devel libxslt-devel redhat-rpm-config tidy \
dejavu-fonts-common-2.35 dejavu-serif-fonts-2.35 linux-libertine-biolinum-fonts-5.3.0 \
linux-libertine-fonts-5.3.0 linux-libertine-fonts-common-5.3.0 unifont-9.0.06 \
unifont-fonts-9.0.06 dejavu-sans-mono-fonts.noarch java-1.8.0-openjdk-headless.x86_64

# Language issues
RUN /bin/echo 'LANG=en_US.UTF-8' >/etc/locale.conf
ENV LANG en_US.UTF-8

# User setup
RUN mkdir /srv/cll
WORKDIR /srv/cll
RUN echo 'cll    ALL=(ALL)    NOPASSWD: ALL' >>/etc/sudoers.d/cll

# Ruby setup
COPY Gemfile Gemfile.lock /srv/cll/
RUN gem install bundler
RUN bundle config --global silence_root_warning true 
RUN bundle config build.nokogiri --use-system-libraries
RUN bundle install

# Prince XML Setup
RUN cd /usr/src ; wget https://www.princexml.com/download/prince-10r7-1.centos7.x86_64.rpm
RUN dnf -y install /usr/src/prince-10r7-1.centos7.x86_64.rpm

# Stuff to do on "boot"
COPY docker_init.sh /tmp/docker_init.sh
RUN sudo dos2unix /tmp/docker_init.sh
RUN sudo chmod 755 /tmp/docker_init.sh
