# @description A parsed manifest for a package.
ifneq "$(MANIFEST_MK)" "1"

include ${environment.margo_root}package_ref.mk

# class manifest {
#   string name
#   string version
#   string description
#   package_ref dependencies[]
# }

# @brief   Resets the state of any local variables in the manifest file.
# @warning Use with `eval` only.
define manifest.reset
    name :=
    version :=
    description :=

    $$(foreach d,$$(filter dependency[%,$${.VARIABLES}),$$(eval undefine $${d}))
endef

# @brief   Parses the manifest file and sets appropriate variables.
# @param1  Name of the class instance.
# @param2  Manifest file to parse.
# @warning Use with `eval` only.
define manifest.parse
    $$(eval $$(call manifest.reset))

    include ${2}

    ${1}.name := $${name}
    ${1}.version := $${version}
    ${1}.description := $${description}

    define local.add_package
        ifneq "$${d}" ""
            ${1}.dependencies += $${d}
            $$(call package_ref.create,${1}.dependencies.$${d},$${d},$${dependency[$${d}]})
        endif
    endef

    $$(foreach d,$$(patsubst dependencies.%,%,$$(filter dependencies.%,$${.VARIABLES})),\
        $$(eval $${local.add_package}))
endef

# @brief   Loads a package manifest from the supplied directory.
# @param1  Name of the class instance.
# @param2  Directory of the package.
# @warning Use with `eval` only.
define manifest.load
    local.filename := ${2}/manifest.mk

    ifeq "$$(wildcard $${local.filename})" ""
        $$(error Could not find a file named 'manifest.mk' in '${2}'.)
    endif

    $$(eval $$(call manifest.parse,${1},$${local.filename}))
endef

MANIFEST_MK := 1
endif
