#! @bash@/bin/sh
PATH=@coreutils@/bin:@procps@/bin:@bubblewrap@/bin:@electron@/bin:@lsb_release@/bin
wechat_pid=`pidof wechat-uos`
if test $wechat_pid ;then
    kill -9 $wechat_pid
fi
bwrap --dev-bind / / \
    --bind @out@/usr/share/wechat-uos/etc/os-release /etc/os-release \
    --bind @out@/usr/share/wechat-uos/etc/lsb-release /etc/lsb-release \
    --bind @out@/usr/lib/wechat-uos/license/ /usr/lib/license/ \
    --bind @out@/usr/share/wechat-uos/var/ /var/ \
    electron /usr/lib/wechat-uos "$@"
