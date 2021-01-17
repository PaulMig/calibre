FROM debian:buster
ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

RUN sed -i 's/# deb/deb/g' /etc/apt/sources.list

RUN apt-get update &&\
    apt-get -y upgrade && \
    apt-get install -y sudo && \
    sudo apt-get install -y systemd systemd-sysv && \
    sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN cd /lib/systemd/system/sysinit.target.wants/ && \
    ls | grep -v systemd-tmpfiles-setup | xargs rm -f $1

RUN rm -f /lib/systemd/system/multi-user.target.wants/* \
    /etc/systemd/system/*.wants/* \
    /lib/systemd/system/local-fs.target.wants/* \
    /lib/systemd/system/sockets.target.wants/*udev* \
    /lib/systemd/system/sockets.target.wants/*initctl* \
    /lib/systemd/system/basic.target.wants/* \
    /lib/systemd/system/anaconda.target.wants/* \
    /lib/systemd/system/plymouth* \
    /lib/systemd/system/systemd-update-utmp*

RUN sudo apt-get install -y apt-utils && \
    sudo apt-get install -y libfontconfig libgl1-mesa-glx && \
    sudo apt-get install -y wget && \
    sudo apt-get install -y python && \
    wget https://download.calibre-ebook.com/linux-installer.sh && \
    sudo sh linux-installer.sh && \
    useradd -m docker && echo "docker:docker" | chpasswd && adduser docker sudo && \
    chown docker:docker ~/.config/ && \
    mkdir calibre-library && \
    mkdir ~/books-to-add && \
    wget http://www.gutenberg.org/ebooks/46.kindle.noimages -O christmascarol.mobi && \    
    calibredb add *.mobi --with-library calibre-library/ && \
    touch /etc/systemd/system/calibre-server.service && \
    cat >/etc/systemd/system/calibre-server.service <<'EOL'
    ## startup service
    [Unit]
    Description=calibre content server
    After=network.target
    [Service]
    Type=simple
    User=docker
    Group=docker
    ExecStart=/opt/calibre/calibre-server /home/docker/calibre-library --enable-local-write --enable-auth
    [Install]
    WantedBy=multi-user.target
    EOL && \
    sudo systemctl enable calibre-server

VOLUME [ "/sys/fs/cgroup" ]

CMD ["/lib/systemd/systemd"]
