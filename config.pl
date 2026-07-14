# Set the chroot mode to be unshare.
$chroot_mode = 'unshare';

$external_commands = { "build-failed-commands" => [ [ '%SBUILD_SHELL' ] ] };

# Uncomment below to specify the distribution; this is the same as passing `-d unstable` to sbuild.
# Specifying the distribution is currently required for piuparts when the changelog targets UNRELEASED.  See #1088928.
#$distribution = 'experimental';
$distribution = 'stable';
#$distribution = 'bookworm-backports';

# Specify an extra repository; this is the same as passing `--extra-repository` to sbuild.
$extra_repositories = ['deb [trusted=yes] http://pve.loongfans.cn stable main'];
#$extra_repositories = ['deb http://deb.debian.org/debian experimental main'];

# Specify extra local packages to make available to the build environment.
# The paths must be absolute paths from root; this is the same as passing `--extra-package` to sbuild.
#$extra_packages = ['/home/build/debs/'];

# Specify the build dependency resolver; this is the same as passing `--build-dep-resolver` to sbuild.
# When building with extra repositories, often 'aptitude' is better than 'apt' (the default).
$build_dep_resolver = 'aptitude';

# Specify the exact version of a required dependency; this is the same as passing `--add-depends` to sbuild.
#$manual_depends = ['foo-dev (>= 1.2.3-4)', 'bar (>= 5.0-1)'];

# Build Architecture: all packages; this is the same as passing `-A` to sbuild.
$build_arch_all = 1;

# Build the source in addition to the other requested build artifacts.
# Without this, <BINARY>.changes files will not include the upstream source in
# their list and will fail uploads to Debian if they are for a -1 revision that
# includes a new upstream release; this is the same as passing `-s` to sbuild.
$build_source = 1;

# Produce a source.changes file suitable for a source-only upload;
# this is the same as passing `--source-only-changes` to sbuild.
$source_only_changes = 1;

## Run lintian after every build (in the same chroot as the build); use --no-run-lintian to override.
$run_lintian = 0;
# Display info tags.
$lintian_opts = ['--display-info', '--verbose', '--fail-on', 'error,warning', '--info'];
# Display info and pedantic tags, as well as overrides.
#$lintian_opts = ['--display-info', '--verbose', '--fail-on', 'error,warning', '--info', '--pedantic', '--show-overrides'];

## Run autopkgtest after every build (in a new, clean, chroot); use --no-run-autopkgtest to override.
$run_autopkgtest = 0;
# Specify autopkgtest options.  The commented example below is the default since trixie.
#$autopkgtest_opts = ['--apt-upgrade', '--', 'unshare', '--release', '%r', '--arch', '%a' ];

## Run piuparts after every build (in a new, temporary, chroot); use --no-run-piuparts to override.
# this does not work in bookworm
$run_piuparts = 0;
# Build a temporary chroot.
$piuparts_opts = ['--no-eatmydata', '--distribution=%r', '--fake-essential-packages=systemd-sysv'];
# Build a temporary chroot that uses apt-cacher-ng as a proxy to save bandwidth and time and doesn't disable eatmydata to speed up processing.
#$piuparts_opts = ['--distribution=%r', '--bootstrapcmd=mmdebstrap --skip=check/empty --variant=minbase --aptopt="Acquire::http { Proxy \"http://127.0.0.1:3142\"; }"'];
