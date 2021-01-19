FROM jrei/systemd-debian

run apt update -y && \
    apt upgrade -y && \
    apt install -y wget && \
    apt install -y python && \
    apt install -y nano && \
    apt install -y sudo && \
    sudo apt install -y libfontconfig libgl1-mesa-glx && \
    wget https://download.calibre-ebook.com/linux-installer.sh && \
    sudo sh linux-installer.sh && \
    useradd -m docker && echo "docker:docker" | chpasswd && adduser docker sudo && \
    chown docker:docker ~/.config/ && \
    wget http://www.gutenberg.org/ebooks/46.kindle.noimages -O christmascarol.mobi && \
    mkdir calibre-library && \
    calibredb add *.mobi --with-library calibre-library/ && \
    # calibre-server calibre-library && \
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
    sudo systemctl enable calibre-server
    # sudo systemctl start calibre-server
