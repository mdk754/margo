.SUFFIXES:
MAKEFLAGS += -r
ECHO_PREFIX := "  "
ECHO := @printf $(ECHO_PREFIX); echo

ifeq ($(verbose), y)
  Q =
else
  Q = @
  MAKEFLAGS += --no-print-directory
endif


# Makefile functions.

RWILDCARD = $(foreach d,$(wildcard $1*),$(call RWILDCARD,$d/,$2) $(filter $(subst *,%,$2),$d))
ASSERT = $(if $(1),$(1),$(error $(2)))
ASSERT_NOT = $(if $(1),$(error $(2)),$(1))
GET_REPO = $(call ASSERT,$(word 1,$($(patsubst %/,%,$(1)))),Repository for $(1) not found!)
GET_SEMVER = $(call ASSERT,$(word 2,$($(patsubst %/,%,$(1)))),Version requirement for $(1) not found!)


# Project variables.

export WORKSPACE ?= $(HOME)/.margo
export GLOBALCACHEDIR ?= $(WORKSPACE)/cache
export GLOBALDEPDIR ?= $(WORKSPACE)/dep

export SRCDIR ?= $(CURDIR)/src
export BUILDDIR ?= $(CURDIR)/build
export BINDIR ?= $(BUILDDIR)/bin
export OBJDIR ?= $(BUILDDIR)/obj
export DEPDIR ?= $(BUILDDIR)/dep
export CACHEDIR ?= $(BUILDDIR)/cache

export target ?= x86_64-linux-gnu
export profile ?= dev
export optimize ?= n
export debug ?= y

ifeq ($(MARGO),)
	export MARGO := $(Q)$(MAKE) -f $(lastword $(MAKEFILE_LIST))
endif


# Project manifest.

-include margo.mk


# Dependency resolver.

$(GLOBALDEPDIR)/%/repo.git:
	$(Q)mkdir -p $(dir $@)
	$(ECHO) "$(Q)git clone --bare $(call GET_REPO,$*) $@"
	$(Q)touch $@

FETCH_DEP = $(addprefix $(GLOBALDEPDIR)/,$(addsuffix /repo.git,$(1)))


# Top-level targets.

.PHONY: new
new: pkgid?=$(notdir $(CURDIR))
new:
	$(call ASSERT_NOT,$(shell ls -A "$(CURDIR)"),Current directory not empty!)
	$(Q)printf 'pkgid = $(pkgid)\npkgver = 0.1.0\n\ndependencies =\n' > margo.mk
	$(Q)mkdir -p inc/$(pkgid)
	$(Q)mkdir -p src
	$(Q)git init >/dev/null
	$(ECHO) "Created \`$(pkgid)\` package"

.PHONY: release
release: profile = release
release: optimize = y
release: debug = n
release: build

.PHONY: build
build: BUILD_ID=$(call ASSERT,$(shell mkdir -p $(CACHEDIR) && mktemp -dp $(CACHEDIR) XXXXXXXXXXXXXXXX),Failed to generate BUILD_ID!)
build: $(call FETCH_DEP,$(dependencies))
	$(Q)$(RM) -r $(BUILD_ID)
	$(ECHO) "Finished $(profile) [$(if $(filter $(optimize), y),optimized,unoptimized)$(if $(filter $(debug), y), + debuginfo,)] target(s)"

.PHONY: clean
clean:
	$(Q)$(RM) -r $(CACHEDIR)

.PHONY: clobber
clobber: clean
	$(Q)$(RM) -r $(GLOBALDEPDIR)

.PHONY: help
help:
	$(ECHO) 'To be continued...'
