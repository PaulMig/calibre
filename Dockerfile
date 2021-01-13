FROM ubuntu
EXPOSE 8080/tcp 8081/tcp
RUN apt-get update -y &&\
    
    apt-get install -y sudo && \
    sudo apt-get -y upgrade && \
    sudo apt-get install -y apt-utils && \
    sudo apt-get install -y systemd && \
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
    sudo systemctl start calibre-server
