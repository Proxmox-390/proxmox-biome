include /usr/share/dpkg/pkg-info.mk

PACKAGE=proxmox-biome

DEB=$(PACKAGE)_$(DEB_VERSION_UPSTREAM_REVISION)_amd64.deb
DEB_DBG=$(PACKAGE)-dbgsym_$(DEB_VERSION_UPSTREAM_REVISION)_amd64.deb

BUILDDIR=$(PACKAGE)-$(DEB_VERSION_UPSTREAM)

# fix up ~ used to lower version for betas
BIOME_VERSION ?= $(subst ~,-,$(DEB_VERSION_UPSTREAM))
BIOME_DIR=biome

all: $(DEB)

# FIXME: check for rustup - toolchainversions matching vautwarden/rust-toolchain)
update:
	git subtree pull --squash --prefix $(BIOME_DIR) \
	    -m "Update biome subtree to $(BIOME_VERSION)" \
	    https://github.com/biomejs/biome.git \
	    "@biomejs/biome@$(BIOME_VERSION)"
	cargo vendor --locked --manifest-path $(BIOME_DIR)/Cargo.toml vendor
	# reduce size by dropping unused Windows artefacts as we cannot remove
	# the crates without touching a lot of Cargo.toml files
	find vendor/win* -type f \( -name '*.a' -o -name '*.lib' \) -print -delete
	find vendor/windows*/src/ vendor/winapi*/src/ \! -name 'lib.rs' -type f -print -delete
	git add --force vendor/
	git commit -sm 'vendor dependencies for biome $(BIOME_VERSION)'

.PHONY: deb builddir dinstall
builddir:
	rm -rf $(BUILDDIR)
	$(MAKE) $(BUILDDIR)

$(BUILDDIR):
	rm -rf $@ $@.tmp
	cp -a $(BIOME_DIR)/ $@.tmp
	cp -a vendor/ $@.tmp/vendor
	cp -a Makefile $@.tmp/
	cp -a debian/ $@.tmp/debian
	cp -a src/ $@.tmp/src
	printf '\n[source.crates-io]\nreplace-with = "vendored-sources"\n\n[source.vendored-sources]\ndirectory = "vendor"\n' \
	  >> $@.tmp/.cargo/config.toml
	mv $@.tmp $@

install:
	install -d $(DESTDIR)/usr/bin/
	install -m 0755 target/release/biome $(DESTDIR)/usr/bin/biome

deb: $(DEB)
$(DEB) $(DEB_DBG) &: $(BUILDDIR)
	cd $(BUILDDIR); dpkg-buildpackage -b -us -uc
	lintian $(DEB)

.PHONY: upload
upload: $(DEB) $(DEB_DBG)
	tar cf - $(DEB) $(DEB_DBG) | ssh repoman@repo.proxmox.com -- upload --product devel --dist bookworm

dinstall: deb
	dpkg -i $(DEB)

.PHONY: clean
clean:
	rm -rf *~ debian/*~ *.deb *.changes *.buildinfo $(PACKAGE)-[0-9]*/

.PHONY: distclean
distclean: clean

