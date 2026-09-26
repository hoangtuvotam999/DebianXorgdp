FROM debian:bullseye
ENV DEBIAN_FRONTEND=noninteractive
RUN dpkg --add-architecture i386

RUN apt update && apt install -y --no-install-recommends \
    xrdp \
    xorgxrdp \
    xfce4 \
    xfce4-terminal \
    xfce4-taskmanager \
    xorg \
    dbus-x11 \
    sudo \
    curl \
    wget \
    nano \
    net-tools \
    policykit-1 \
    fonts-noto-color-emoji \
    wine \
    wine32 \
    firefox-esr && \
    apt clean && rm -rf /var/lib/apt/lists/*

# root password
RUN echo "root:root" | chpasswd

RUN sed -i 's/^allowed_users=.*/allowed_users=anybody/' /etc/X11/Xwrapper.config || \
    echo "allowed_users=anybody" >> /etc/X11/Xwrapper.config

RUN echo "startxfce4" > /root/.xsession && chmod 700 /root/.xsession

RUN mkdir -p /var/run/dbus && dbus-uuidgen > /var/lib/dbus/machine-id

RUN sed -i \
    -e 's/security_layer=negotiate/security_layer=rdp/' \
    -e 's/crypt_level=high/crypt_level=low/' \
    -e 's/max_bpp=32/max_bpp=16/' \
    -e 's/^use_compression=.*/use_compression=yes/' \
    -e 's/^tcp_nodelay=.*/tcp_nodelay=yes/' \
    -e 's/^tcp_keepalive=.*/tcp_keepalive=yes/' \
    /etc/xrdp/xrdp.ini && \
    echo "exec startxfce4" > /etc/xrdp/startwm.sh && \
    chmod +x /etc/xrdp/startwm.sh

# ssl-cert xrdp
RUN adduser xrdp ssl-cert

RUN mkdir -p /root/.config/xfce4/xfconf/xfce-perchannel-xml && \
    printf '<?xml version="1.0" encoding="UTF-8"?>\n<channel name="xfwm4" version="1.0">\n  <property name="general" type="empty">\n    <property name="use_compositing" type="bool" value="false"/>\n  </property>\n</channel>\n' \
    > /root/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml
RUN mkdir -p /root/.config/pulse && \
    printf 'autospawn = no\ndaemon-binary = /bin/true\n' \
    > /root/.config/pulse/client.conf

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3389

CMD ["/start.sh"]
