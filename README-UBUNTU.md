# Install prequisites

```
sudo apt-get install wget xsltproc xmlto fonts-dejavu fonts-linuxlibertine unifont ruby-full zip unzip default-jdk`
gem install bundler
bundle install

#install epub lib:
sudo -v && wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sudo sh /dev/stdin
#Xvfb and xvfb-run (fake X for calibre) or a running X server session -- MAYBE NOT ACTUALLY NEEDED

sudo apt-get install python-pip
sudo apt-get install xvfb xserver-xephyr vnc4server
sudo pip install pyvirtualdisplay
# optional
sudo apt-get install python-pil scrot
sudo pip install pyscreenshot

# install Prince for your platform from https://www.princexml.com/download/ e.g.:
wget https://www.princexml.com/download/prince_12.5-1_ubuntu18.04_amd64.deb
sudo apt install ./prince_12.5-1_ubuntu18.04_amd64.deb
```



There might be other libs needed. Please, open an issue once you find it.

# Compilation

To make all the versions do:

`./cll_build`

The final results will end up under the build/ directory, scattered
about in various places.  If you would like the final outputs only
to be copied to another directory, you can use the -a option, so for example:

`./cll_build -a output/`

would put all the outputs in the output/ directory, whereas

`./cll_build -a ~/public_html/cll_build/`

would put them in your personal webspace.

Running a complete build takes quite a while (like probably at least
an hour).  To do it for just one chapter for faster testing:

`./cll_build -t chapters/05.xml`

This does the whole book but is also much faster:

`./cll_build -t`

There are many possible sub-targets as well, which are specified
with -T, such as:

`./cll_build -t -T pdf`

You can get a complete list of targets via:

`./cll_build -h`
