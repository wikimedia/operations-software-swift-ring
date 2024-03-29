DESTHOST=
TARGETS=eqiad-prod esams-prod codfw-prod thanos-prod

BUILDER_FILES=$(foreach dir,$(TARGETS),$(wildcard $(dir)/*.builder))
RING_FILES=$(foreach builder,$(BUILDER_FILES),$(subst .builder,.ring.gz,$(builder)))
DUMP_FILES=$(foreach builder,$(BUILDER_FILES),$(subst .builder,.dump,$(builder)))
DISPERSION_FILES=$(foreach builder,$(BUILDER_FILES),$(subst .builder,.dispersion,$(builder)))

quit:
	$(error "OBSOLETE: see https://wikitech.wikimedia.org/wiki/Swift/Ring_Management")

rebuild: quit $(RING_FILES) $(DUMP_FILES) $(DISPERSION_FILES)

%.dump: %.builder
	swift-ring-builder $^ > $@

%.dispersion: %.builder
	swift-ring-builder $^ dispersion --verbose > $@ ; [ $$? -le 1 ] || exit 2

%.ring.gz: %.builder
# don't fail when rebalance exits 1 (nothing has been done)
	swift-ring-builder $^ rebalance ; [ $$? -le 1 ] || exit 2
	swift-ring-builder $^ write_ring

# TODO(fgiunchedi): rsync HEAD, not the working tree
deploy: quit
	[ -n "$(DESTHOST)" ] || { echo 'set DESTHOST to deploy'; exit 1; }
	rsync --progress --verbose --archive --compress --relative \
		$(RING_FILES) $(BUILDER_FILES) $(DESTHOST):swift-ring
	ssh $(DESTHOST) "sudo rsync --verbose --backup --recursive \
		--links --times --chmod=a=r,Da+x \
		swift-ring/ /var/lib/puppet/volatile/swift/"

clean:
	-rm */backups/*
	rm -v $(DUMP_FILES) $(DISPERSION_FILES)

ring_clean:
	rm -v $(RING_FILES)

.PHONY: deploy clean ring_clean
