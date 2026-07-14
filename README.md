# Proxmox VE Loong64 Port

This is a guide for working on the current port of Proxmox VE on LoongArch64. If
you already have a working Proxmox VE Loong64 installation, you can skip the
[Bootstrapping](#bootstrapping) section.

## Prerequisites

1. Obtain a working Proxmox VE Loong64 installation, or a Debian 13
   ([Loong13](https://loong13.debian.net)) installation if you are
   bootstrapping Proxmox VE.
2. Install following build tools on your system:
   ```bash
   apt install sbuild mmdebstrap uidmap piuparts devscripts debcargo build-essentials sudo
   ```
3. Create a unpriveleged user dedicated for building packages:
   ```bash
   useradd -aG wheel build
   ```
   Then switch to the user or login to the user:
   ```bash
   su - build
   ```
4. Prepare the build chroot environment tarball sbuild, see
   [sbuild](https://wiki.debian.org/sbuild) for more information.
   ```
   mkdir -p ~/.cache/sbuild ~/.config/sbuild
   mmdebstrap \
       --include=ca-certificates,debian-loong64-non-official-archive-keyring \
       --skip=output/dev --variant=buildd stable \
       ~/.cache/sbuild/stable-loong64-sbuild.tar /etc/apt/sources.list
   ```
   Then copy the sbuild [config.pl](config.pl) file to `~/.config/sbuild/`.
> [!NOTE]
> For bootstrapping, remove or comment out the line starting with
> `$extra_repositories` to disable the usage of Proxmox VE Loong64
> repository.
5. Read [Build Instructions](#build-instructions) if you are working with an
   existing Proxmox VE Loong64 installation or [Bootstrapping](#bootstrapping)
   if you are bootstrapping from Debian 13.

## Build Instructions
> [!NOTE]
> This section only works for a bootstrapped environment, for bootstrapping
> Proxmox VE Loong64 port, read [Bootstrapping](#bootstrapping) first, and then
> follow the instructions here.

### Proxmox Projects
Most Proxmox VE projects ship a Makefile to simplify the building and packaging
process, we use `pve-manager` in this guide as an example.

Proxmox hosts all open source repositories at <https://git.proxmox.com>.

1. Clone the repository and `cd` into the directory:
   ```bash
   git clone git://git.proxmox.com/git/pve-manager.git
   cd pve-manager
   ```
2. If the repository has a Loong64 port repository on
   <https://github.com/pve-loong64-port>, add the corresponding repository as a
   downstream remote and track the downstream `master` branch:
   ```bash
   git remote add loong64 https://github.com/pve-loong64-port/pve-manager.git
   git fetch loong64
   git branch -u loong64/master
   git reset --hard loong64/master
   ```
3. Build the packages:
   ```bash
   make sbuild
   ```
   This will build the `dsc` Debian source control file, the Debian source
   package, and then use `sbuild` to build the packages in a chrooted
   environment.

   After finishing the building process, `deb` Debian package files are present
   in the current directory.
4. Cleaning the repository after finishing everything:
   ```bash
   make clean
   ```

In case `sbuild` target does not exist in the Makefile, you may use the
following commands to manually call sbuild:
```bash
make dsc
sbuild *.dsc
```

### Proxmox `debcargo-conf` Rust Crates
Proxmox requires some newer Rust crates backported to Debian 13. These Rust
crate packages are built from
[debcargo-conf](https://git.proxmox.com/?p=debcargo-conf.git) repository.

We will use `xdg` crate as an example here.

1. Clone the repository and `cd` into the directory:
   ```bash
   git clone git://git.proxmox.com/git/debcargo-conf.git
   cd debcargo-conf
   ```
2. Replace Debian official repositories with Loong13 repositories in `build.sh`,
   see <https://loong13.debian.net> for more information.
3. Use `repackage.sh` to prepare the crate for packaging:
   ```bash
   ./repackage.sh xdg
   ```
4. `cd` into `build` directory, use `build.sh` to start packaging:
   ```bash
   cd build
   ./build.sh xdg
   ```
> [!NOTE]
> If a dependency error occurred, go back to step 3 to repackage and build
> the missing crate, and upload the built `deb` packages to your repository,
> or append these packages to `./build.sh` as arguments after the target
> crate name.
5. Build artifacts including `deb` Debian packages and Debian source packages
   are present in the current directory.

## Bootstrapping

First, build required Rust crate packages from `debcargo-conf` following
[Proxmox `debcargo-conf` Rust Crates](#proxmox-debcargo-conf-rust-crates) guide.

Follow the list of crates below to build in order:
<details>
<summary>List of required Rust crates</summary>

```
endian_trait_derive
endian_trait
httparse
hyper
hyper-util
serde_plain
tracing-journald
base64urlsafedata
compact_jwt
serde_cbor_2
webauthn-attestation-ca
serde-wasm-bindgen
wasm-bindgen-shared
wasm-bindgen-macro-support
wasm-bindgen-macro
wasm-bindgen
js-sys
web-sys
webauthn-rs-proto
webauthn-rs-core
webauthn-rs
apt-pkg-native
lber
x509-parser
ldap3
email-encoding
lettre
hashify
mail-parser
oci-spec
getrandom
oauth2
openidconnect
openssl-probe
async-stream
minijinja
xdg
gloo-events
gloo-utils
pulldown-cmark-escape
pulldown-cmark
implicit-clone
gloo-console
gloo-dialogs
gloo-file
gloo-history
gloo-net
gloo-render
gloo-storage
gloo-worker-macros
pinned
gloo-worker
gloo
prokio
boolinator
yew-macro
yew
wasm-logger
yew-router-macro
yew-router
codemap
abomonation
deepsize_derive
deepsize
lasso
grass-compiler
include_sass
grass
walrus-macro
leb128fmt
wasmparser
wasm-encoder
walrus
wasm-bindgen-cli-support
xtr
cidr
pxar
cursive_core
```

</details>

Then, build everything in
[proxmox.git](https://git.proxmox.com/?p=proxmox.git;a=summary) with the
command, following the dependency order in each crate:
```bash
make <crate>-deb
```

Follow [the build instructions for Proxmox projects](##proxmox-projects), build
the rest of the components of Proxmox VE in order:
<details>
<summary>List of required Proxmox VE repositories</summary>

```
proxmox
perlmod
proxmox-ve-rs
proxmox-perl-rs
pve-common
proxmox-archive-keyring
proxmox-kernel-helper
pve-firmware
pve-kernel
pve-kernel-meta
pve-apiclient
proxmox-biome
proxmox-widget-toolkit
extjs
proxmox-yew-widget-toolkit
proxmox-yew-comp
proxmox-wasm-builder
proxmox-mini-journalreader
pve-xtermjs
proxmox-i18n
pve-docs
proxmox-datacenter-manager
proxmox-datacenter-manager-meta
pve-access-control
pve-cluster
ceph
librados2-perl
pathpatterns
pxar
proxmox-fuse
libjs-qrcodejs
proxmox-backup
proxmox-backup-meta
zfsonlinux
pve-storage
proxmox-websocket-tunnel
pve-guest-common
pve-firewall
pve-network
lxc
pve-lxc-syscalld
pve-edk2-firmware
proxmox-backup-qemu
pve-qemu
qemu-server
pve-ha-manager
pve-container
pve-http-server
fonts-font-logos
novnc-pve
proxmox-mail-forward
pve-yew-mobile-gui
spiceterm
vncterm
pve-manager
proxmox-ve
proxmox-firewall
apparmor
corosync-pve
frr
fwupd
fwupd-efi
grub2
ifupdown2
kronosnet
libarchive-perl
libpve-u2f-server-perl
libtpms
libxdgmime-perl
lxcfs
proxmox-rrd-migration-tool
pve-installer
pve-zsync
smartmontools
swtpm
proxmox-network-interface-pinning
proxmox-offline-mirror
pve-esxi-import-tools
vma-to-pbs
```

</details>
