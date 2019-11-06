include lib/array.mk
include lib/table.mk
include lib/manifest.mk

-include ${CURDIR}/example/fooapp/manifest

.PHONY: all
all:
	@true
