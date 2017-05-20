FROM phusion/baseimage:0.9.19

ENV ASTERISKUSER asterisk
ENV ASTERISKVER 14.1.2
ENV PJPROJECTVER 2.5.5

RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends curl build-essential libxml2-dev libncurses5-dev libsqlite3-dev libssl-dev libxslt-dev libjansson-dev libreadline-dev libreadline6-dev libnewt-dev uuid-dev libsnmp-dev libsrtp0-dev libboost-iostreams1.58.0 libcgi-fast-perl libcgi-pm-perl libwww-perl libclass-accessor-perl libcwidget3v5 libencode-locale-perl libfcgi-perl libhtml-parser-perl libhtml-tagset-perl libhttp-date-perl libhttp-message-perl libio-html-perl libio-string-perl liblocale-gettext-perl liblwp-mediatypes-perl libsub-name-perl libtimedate-perl liburi-perl mpg123 sox libvorbis-dev libiksemel-dev libspeexdsp-dev make git subversion unzip pkg-config

# Installing res_pjsip dependency
WORKDIR /tmp
RUN curl -O http://www.pjsip.org/release/$PJPROJECTVER/pjproject-$PJPROJECTVER.tar.bz2 \
	&& tar -jxvf pjproject-$PJPROJECTVER.tar.bz2
WORKDIR /tmp/pjproject-$PJPROJECTVER
RUN ./configure CFLAGS="-O2 -DNDEBUG" --prefix=/usr --libdir=/usr/lib/x86_64-linux-gnu --enable-shared --disable-video --disable-resample --disable-sound --disable-opencore-amr
RUN make dep 1> /dev/null && make 1> /dev/null && make install && ldconfig -v | grep pj

# Installing Asterisk
WORKDIR /tmp
RUN curl -O http://downloads.asterisk.org/pub/telephony/asterisk/releases/asterisk-$ASTERISKVER.tar.gz \
	&& tar -xvzf asterisk-$ASTERISKVER.tar.gz
WORKDIR /tmp/asterisk-$ASTERISKVER
RUN contrib/scripts/get_mp3_source.sh
RUN ./configure --with-crypto --with-ssl CFLAGS='-g -O2 -mtune=native'
RUN cd menuselect && make menuselect && cd .. & make menuselect-tree
RUN menuselect/menuselect \
	--disable BUILD_NATIVE \
	--enable cdr_csv \
	--enable res_snmp \
	--enable res_http_websocket \
	--enable res_pjsip \
        --enable res_pjsip_config_wizard \
	--enable res_srtp \
        --enable format_mp3 \
	menuselect/menuselect.makeopts \
RUN make 1> /dev/null && make install && make samples

# Installing Google TTS script
WORKDIR /tmp
RUN curl -o googletts-latest.zip https://codeload.github.com/zaf/asterisk-googletts/zip/master \
	&& unzip googletts-latest.zip \
	&& cp asterisk-googletts-master/googletts.agi /var/lib/asterisk/agi-bin/

# Add phone spammer update script
COPY blacklist/update-blacklist.sh /usr/local/bin/

# Creating Asterisk user and set permissions
RUN useradd -m $ASTERISKUSER -U -s /sbin/nologin --home-dir /var/lib/asterisk
RUN chown -R $ASTERISKUSER:$ASTERISKUSER /var/lib/asterisk \
	&& chown -R $ASTERISKUSER:$ASTERISKUSER /var/spool/asterisk \
	&& chown -R $ASTERISKUSER:$ASTERISKUSER /var/log/asterisk \
	&& chown -R $ASTERISKUSER:$ASTERISKUSER /var/run/asterisk \
	&& chown -R $ASTERISKUSER:$ASTERISKUSER /etc/asterisk

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh && rm -rf /tmp/*

WORKDIR /var/lib/asterisk
USER $ASTERISKUSER
ENTRYPOINT ["/entrypoint.sh"]
CMD ["sh", "-c", "/usr/sbin/asterisk -fvvv -U ${ASTERISKUSER} -G ${ASTERISKUSER}"]
