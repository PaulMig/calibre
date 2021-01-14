FROM ubuntu:20.04
ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

RUN sed -i 's/# deb/deb/g' /etc/apt/sources.list

RUN apt-get update &&\
    apt-get install -y sudo && \
    apt-get install -y systemd systemd-sysv && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

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

RUN apt-get update -y &&\
    apt-get install -y sudo && \
    sudo apt-get -y upgrade && \
    sudo apt-get install -y apt-utils && \
    sudo apt-get install -y systemd systemd-sysv && \
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
    echo '## startup service\n\
    [Unit]\n\
    Description=calibre content server\n\
    After=network.target\n\
    [Service]\n\
    Type=simple\n\
    User=docker\n\
    Group=docker\n\
    ExecStart=/opt/calibre/calibre-server /home/docker/calibre-library --enable-local-write\n\
    [Install]\n\
    WantedBy=multi-user.target\n'\
    >> /etc/systemd/system/calibre-server.service && \
    sudo systemctl enable calibre-server && \
    # calibre-server --manage-users --username paul --password password && \
    echo 'ExecStart=/opt/calibre/calibre-server /home/docker/calibre-library --enable-local-write --enable-auth\n'\ 
    >> /etc/systemd/system/calibre-server.service
    # sudo systemctl daemon-reload

VOLUME [ "/sys/fs/cgroup" ]

CMD ["/lib/systemd/systemd"]
