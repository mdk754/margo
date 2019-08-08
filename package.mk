# @description A named and versioned package on disk.
ifneq "$(PACKAGE_MK)" "1"

include ${environment.margo_root}manifest.mk

# class package {
#   manifest spec
#   string path
# }

# @brief   Loads a package from the supplied directory.
# @param1  Name of the class instance.
# @param2  Directory of the package.
# @warning Use with `eval` only.
define package.load
    ${1}.path := ${2}
    $$(eval $$(call manifest.load,${1}.spec,${2},${3}))
endef

PACKAGE_MK := 1
endif
