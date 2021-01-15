ifneq "${mod_manifest}" "1"

include ${margo_path}/lib/package_ref.mk

# @brief   Loads a package manifest file.
# @param1  Instance prefix.
# @param2  Path to manifest file.
# @warning Use with `eval` only.
define mod_manifest.load
  ifeq "$(wildcard ${2})" ""
    $$(info error: manifest file `${2}` does not exist.)
    $$(info )
    $$(error Fatal)
  endif

  include ${2}

  ${1}.name := $${name}
  ${1}.description := $${description}
  ${1}.version := $${version}
  ${1}.dev_dependencies := $${dev_dependencies}

  ${1}.dependencies :=

  define local.add_package_helper
    ifneq "$${2}" ""
      $${1} := $$(strip $${$${1}} $${2})
      $$(eval $$(call mod_package_ref.create,$${1}.$${2},$${2},dependency.$${2}))
    endif
  endef

  $$(foreach dep,$$(patsubst dependency.%,%,$$(filter dependency.%,$${.VARIABLES})),\
    $$(eval $$(call local.add_package_helper,${1}.dependencies,$${dep})))

  $$(eval $$(call mod_manifest.reset))
endef

# @brief   Gets the package name from a manifest file.
# @param1  Path to manifest file.
# @param2  Ref to output string.
# @warning Use with `eval` only.
define mod_manifest.name
  ifeq "$(wildcard ${1})" ""
    $$(info error: manifest file `${1}` does not exist.)
    $$(info )
    $$(error Fatal)
  endif

  include ${1}

  ${2} := $${name}

  $$(eval $$(call mod_manifest.reset))
endef

# @brief   Gets the package version from its manifest file.
# @param1  Path to manifest file.
# @param2  Ref to output string.
# @warning Use with `eval` only.
define mod_manifest.version
  ifeq "$(wildcard ${1})" ""
    $$(info error: manifest file `${1}` does not exist.)
    $$(info )
    $$(error Fatal)
  endif

  include ${1}

  ${2} := $${version}

  $$(eval $$(call mod_manifest.reset))
endef

# @brief   Resets the state of any local variables in the manifest file.
# @warning Use with `eval` only.
define mod_manifest.reset
  name :=
  version :=
  description :=
  dev_dependencies :=

  $$(foreach d,$$(filter dependency.%,$${.VARIABLES}),$$(eval undefine $${d}))
endef

mod_manifest := 1
endif
