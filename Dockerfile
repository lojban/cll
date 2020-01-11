FROM fedora:30

# Initial Setup, Basic Package Installs
RUN dnf -y update
RUN dnf -y remove vim-minimal
RUN dnf -y reinstall shadow-utils  # needed for man pages, dunno why
RUN dnf -y install vim sudo tmux zsh moreutils make moreutils sudo \
      dos2unix strace git the_silver_searcher procps-ng openssh-server \
      initscripts openssh man-db ncurses-compat-libs wget curl \
      libcurl-devel pcre-devel bzip2-devel rsync zlib-devel \
      pkgconfig w3m openssl-devel gcc rubygem-rake fpaste \
      zip unzip psmisc lsof python yum-plugin-ovl glibc-all-langpacks

# Specifically needed packages, with versions where the package is
# important.
RUN dnf -y install xmlto-0.0.28 ruby-devel libxml2-devel \
libxslt-devel redhat-rpm-config tidy dejavu-fonts-common \
dejavu-serif-fonts linux-libertine-biolinum-fonts \
linux-libertine-fonts linux-libertine-fonts-common unifont \
unifont-fonts dejavu-sans-mono-fonts.noarch \
java-1.8.0-openjdk-headless.x86_64

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
RUN cd /usr/src ; wget https://www.princexml.com/download/prince-12.5-1.centos7.x86_64.rpm
RUN dnf -y install /usr/src/prince-12.5-1.centos7.x86_64.rpm
