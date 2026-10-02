.PHONY: clean

DESTDIR ?= debian/openssl-src/usr/src/nell/openssl
VERSION ?= 3.6.4
NAME ?= openssl
export SOURCE_DATE_EPOCH = 728438400
export DEBFULLNAME = badsysadm
export EMAIL = me@badsysadm.com

all: deb-source deb-build

get-source: gencontrol
	dh_clean
	dh_prep
	mkdir -p $(DESTDIR)
	wget -q -O- https://github.com/openssl/openssl/releases/download/openssl-${VERSION}/openssl-${VERSION}.tar.gz | tar -xz -C $(DESTDIR) --strip-components=1

deb-source: get-source gencontrol
	mkdir -p $(DESTDIR)/debian
	cp -rfv rules control changelog $(DESTDIR)/debian/

gencontrol:
	mkdir -p $(DESTDIR)/debian
	echo "Source: $(NAME)" > debian/control
	echo "Maintainer: $(DEBFULLNAME) <$(EMAIL)>" >> debian/control
	echo "Section: src" >> debian/control
	echo "Build-Depends: debhelper-compat (= 13)" >> debian/control
	echo >> debian/control
	echo "Package: $(NAME)-src" >> debian/control
	echo "Architecture: amd64" >> debian/control
	perl -0777 -ne 'if (/Build-Depends:\s*(.*?)(?=\n[A-Z]|\z)/s) { $$v = $$1; $$v =~ s/\n/ /g; $$v =~ s/\s+/ /g; print "Depends: $$v\n"; }' control >> debian/control
	echo "Description: Source package of $(NAME)" >> debian/control

deb-build:
	dh_testdir
	dh_installdeb
	dh_fixperms
	dh_strip_nondeterminism
	dh_md5sums
	rm -rf debian/changelog debian/changelog.dch
	dch --create --empty --package $$(sed -ne 's/^Source: //p' debian/control | head -n1) --newversion ${VERSION}-1 -D stable "Automated pipeline build."
	dh_gencontrol
	mkdir -p /target
	dh_builddeb --destdir=/target/test.deb -- -Zxz -z9
	dh_clean
	rm -rf debian/control

clean:
	rm -rf $(DESTDIR)
