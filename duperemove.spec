Name:           duperemove
Version:        0.13.1
Release:        1%{?dist}
Summary:        Tools for deduplicating extents in filesystems

License:        GPL-2.0
URL:            https://github.com/Brinster71/duperemove
Source0:        %{name}-%{version}.tar.gz

BuildRequires:  gcc
BuildRequires:  make
BuildRequires:  glib2-devel
BuildRequires:  sqlite-devel
BuildRequires:  libuuid-devel
BuildRequires:  xxhash-devel

Requires:       glib2
Requires:       sqlite
Requires:       libuuid
Requires:       xxhash-libs

%description
Duperemove is a tool for finding duplicated extents and submitting them for
deduplication. When given a list of files it will hash their contents on a
block by block basis and compare those hashes to each other, finding and
categorizing extents that match each other.

This version includes progress indicators for hash loading operations, which
is helpful when working with large hashfiles.

%prep
%setup -q -n %{name}-%{version}

%build
make %{?_smp_mflags} PREFIX=%{_prefix}

%install
make install DESTDIR=%{buildroot} PREFIX=%{_prefix} SBINDIR=%{_sbindir} \
    MANDIR=%{_mandir} LIBDIR=%{_libdir}

%files
%license LICENSE
%doc README.md
%{_sbindir}/duperemove
%{_sbindir}/hashstats
%{_sbindir}/btrfs-extent-same
%{_mandir}/man8/duperemove.8*
%{_mandir}/man8/hashstats.8*
%{_mandir}/man8/btrfs-extent-same.8*
%{_mandir}/man8/show-shared-extents.8*
%{_datadir}/zsh/site-functions/_duperemove

%changelog
* Mon Apr 28 2025 Travis User <travis@example.com> - 0.13.1-1
- Added progress indicators for hash loading phase
- Shows progress when loading duplicate block and extent hashes
- Progress bars help identify if process is running or crashed
- Particularly useful for large hashfiles (18GB+)

* Sun Jan 01 2023 Upstream - 0.13.0-1
- Initial RPM package
