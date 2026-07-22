FROM gentoo/stage3:systemd
ENV USE="-man -libtommath truetype -introspection -glib -xml -gnutls -fontconfig -drm x264 x265 -v4l -svt-av1 -openh264 -lzma -lv2 -gmp"
RUN emerge --sync
RUN emerge -av net-misc/yt-dlp ffmpeg
CMD ["youtube-dl", "--cookies", "/tmp/cookies.txt", $LINK]
