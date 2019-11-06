# Functions for dealing with  package manifests
ifneq "${mod_manifest}" "1"

# @brief   Resets the state of any local variables in the manifest file.
# @warning Use with `eval` only.
define mod_manifest.reset
    name :=
    version :=
    description :=

    $$(foreach d,$$(filter dependency.%,$${.VARIABLES}),$$(eval undefine $${d}))
endef

# @brief   Parses a manifest file and sets appropriate variables.
# @param1  Prefix of all output variables.
# @param2  Manifest file to parse.
# @warning Use with `eval` only.
define mod_manifest.parse
    $$(eval $$(call mod_manifest.reset))

    include ${2}

    ${1}.name := $${name}
    ${1}.version := $${version}
    ${1}.description := $${description}

    define local.add_package
        ifneq "$${d}" ""
            ${1}.dependencies += $${d}
            $$(call package_ref.create,${1}.dependencies.$${d},$${d},$${dependency.$${d}})
        endif
    endef

    $$(foreach d,$$(patsubst dependency.%,%,$$(filter dependency.%,$${.VARIABLES})),\
        $$(eval $${local.add_package}))
endef

# @brief   Loads a package manifest from the supplied directory.
# @param1  Prefix of all output variables.
# @param2  Directory of the package.
# @warning Use with `eval` only.
define mod_manifest.load
    local.filename := ${2}/manifest

    ifeq "$$(wildcard $${local.filename})" ""
        $$(error Could not find a file named 'manifest' in '${2}'.)
    endif

    $$(eval $$(call mod_manifest.parse,${1},$${local.filename}))
endef

mod_manifest := 1
endif
