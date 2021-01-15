# Functions for dealing with dependencies.
ifneq "${mod_package}" "1"

include ${margo_path}/lib/manifest.mk

asm_src_patterns := %.s %.S %.asm
c_src_patterns := %.c
cxx_src_patterns := %.cc %.cpp %.cxx %.c++
all_src_patterns := ${asm_src_patterns} ${c_src_patterns} ${cxx_src_patterns}

.PHONY: mod_package_run_always
mod_package_run_always:

# @brief   Loads a package from the filesystem.
# @param1  Instance prefix.
# @param2  Path to the package.
# @warning Use with `eval` only.
define mod_package.load
  ifeq "$(wildcard ${2})" ""
    $$(info error: package folder `${2}` does not exist.)
		$$(info )
    $$(error Fatal)
  endif

  ${1}.path := ${2}

  $$(eval $$(call mod_manifest.load,${1}.manifest,${2}/manifest))
endef

# @brief   Creates all target rules for the package.
# @param1  Instance prefix.
# @param2  Path to the build directory.
# @warning Use with `eval` only.
define mod_package.create_rules

${2}/${${1}.manifest.name}:
	@mkdir -p $$@

${2}/${${1}.manifest.name}/prebuild_token: mod_package_run_always $$(foreach dep,$${${1}.manifest.dependencies},${2}/$${dep}/postbuild_token)
	@echo '    Compiling ${${1}.manifest.name} v${${1}.manifest.version}'

${2}/${${1}.manifest.name}/build_script: mod_package_run_always | ${2}/${${1}.manifest.name}/prebuild_token
	@if [ -x "${${1}.path}/build.sh" ]; then \
	  bash -c "${${1}.path}/build.sh" || \
	  ( \
	    echo 'error: package build script `${${1}.path}/build.sh` did not exit successfully.' && \
	    false \
	  ) \
	fi

${1}.src_hash := $$(call mod_package.hash_sources,${1})

${2}/${${1}.manifest.name}/source_files: mod_package_run_always | ${2}/${${1}.manifest.name} ${2}/${${1}.manifest.name}/build_script
	@echo "$${${1}.src_hash}" | cmp -s - $$@ || echo "$${${1}.src_hash}" > $$@

${2}/${${1}.manifest.name}/obj/%.c.o: ${${1}.path}/%.c ${2}/${${1}.manifest.name}/source_files
	@test -z "${Q}" && echo '    Compiling $$<' || true
	@mkdir -p $$(dir $$@)
	@echo $$< > $$@

${2}/${${1}.manifest.name}/postbuild_token: $$(call mod_package.list_objects,${1},${2})

endef

# @brief   Generates a unique hash based on all source filenames.
# @param1  Instance prefix.
mod_package.hash_sources = $(firstword $(shell find ${${1}.path}/src -type f | sort | shasum))

# @brief   Lists all C source files.
# @param1  Instance prefix.
mod_package.list_c_sources = $(shell find ${${1}.path}/src -name '*.c' 2>/dev/null)

# @brief   Lists all source files.
# @param1  Instance prefix.
mod_package.list_sources = $(call mod_package.list_c_sources,${1})

# @brief   Lists all source files.
# @param1  Instance prefix.
# @param2  Path to the build directory.
mod_package.list_objects = $(patsubst ${${1}.path}/%,${2}/${${1}.manifest.name}/obj/%.o,$(call mod_package.list_sources,${1}))

mod_package := 1
endif
