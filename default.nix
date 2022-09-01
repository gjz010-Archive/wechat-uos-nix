{pkgs ? import <nixpkgs> {}}:
with pkgs;
let wechat = stdenvNoCC.mkDerivation {
  pname = "wechat-uos";
  version = "2.1.5";
  src = ./src;
  deb = fetchurl {
    url = "https://home-store-packages.uniontech.com/appstore/pool/appstore/c/com.tencent.weixin/com.tencent.weixin_2.1.5_amd64.deb";
    sha256 = "1091nbf7avp3i45yh8qpsg5chlh17yf4cdgq4z6d8p0gxb1pnlxx";
  };
  buildInputs = [ electron dpkg lsb-release bubblewrap ];
  inherit bubblewrap;
  lsb_release = lsb-release;
  inherit procps;
  inherit bash;
  inherit coreutils;
  inherit electron;
  inherit scrot;
  phases = [ "unpackPhase" "installPhase" ];
  unpackPhase = ''
    echo $electron
    echo "  -> Extracting the deb package..."
    dpkg -x $deb ./deb
    tar -xvf $src/license.tar.gz
  '';

  installPhase = ''
    pkgname=wechat-uos
    echo "  -> Moving stuff in place..."
    mkdir -p $out/usr/lib
    mv deb/opt/apps/com.tencent.weixin/files/weixin/resources/app $out/usr/lib/$pkgname
    install -Dm755 $src/wechat.sh $out/bin/$pkgname
    substituteAllInPlace $out/bin/$pkgname
    echo "  -> Fixing wechat desktop entry..."
    mv deb/usr/share $out/share
    install -Dm644 $src/wechat-uos.desktop $out/share/applications/$pkgname.desktop
    echo "  -> Fixing licenses"
    install -m 755 -d $out/usr/lib/$pkgname
    mv deb/usr/lib/license $out/usr/lib/$pkgname
    chmod 0644 $out/usr/lib/$pkgname/license/libuosdevicea.so
    install -m 755 -d $out/usr/lib/license
    install -m 755 -d $out/usr/share/$pkgname
    cp -r license/etc $out/usr/share/$pkgname
    cp -r license/var $out/usr/share/$pkgname
    echo "  -> Installing scrot"
    cd $out/usr/lib/$pkgname/packages/main/dist
    rm -rf bin{
    mkdir -p bin/scrot
    ln -s ${scrot}/bin/scrot .
  '';
};
wechat-uos-env = stdenvNoCC.mkDerivation{
    meta.priority = 1;
    name  = "wechat-uos-env";
    buildCommand = ''
      mkdir -p $out/etc
      mkdir -p $out/lib
      mkdir -p $out/opt
      ln -s ${wechat}/usr/share/wechat-uos/etc/os-release  $out/etc/os-release
      ln -s ${wechat}/usr/share/wechat-uos/etc/lsb-release  $out/etc/lsb-release
      ln -s ${wechat}/usr/lib/wechat-uos/license  $out/lib/license
      ln -s ${wechat} $out/opt/wechat-root
    '';
    preferLocalBuild = true;
};
in
buildFHSUserEnv{
  inherit (wechat) name meta;
  runScript = "${wechat.outPath}/bin/wechat-uos";
  extraInstallCommands = ''
    mkdir -p $out/share/applications
    mv $out/bin/$name $out/bin/wechat-uos
    ln -s ${wechat.outPath}/share/applications/wechat-uos.desktop $out/share/applications
    cp -r ${wechat.outPath}/share/icons/ $out/share/icons
  '';
  targetPkgs = pkgs: [wechat-uos-env openssl dbus];
  extraOutputsToInstall = ["usr" "var/lib/uos" "var/uos" "etc"];
}
