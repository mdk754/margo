ifneq "${mod_package_ref}" "1"

include ${margo_path}/lib/table.mk
include ${margo_path}/lib/util.mk

# @brief   Creates a package_ref from a string.
# @param1  Instance prefix.
# @param2  Name of the package.
# @param3  Ref to string containing package_ref spec.
# @warning Use with `eval` only.
define mod_package_ref.create
  ${1}.name := ${2}

  local.path := $(call mod_table.get,${3},path)

  ifneq "$$(strip $${local.path})" ""
    ${1}.type := folder
    ${1}.path := $${local.path}
  else
    local.git := $(call mod_table.get,${3},git)

    ifeq "$$(strip $${local.git})" ""
      $$(info error: failed to parse package spec for `${2}`.)
      $$(info )
      $$(error Fatal)
    endif

    ${1}.type := git
    ${1}.git := $${local.git}
    ${1}.ref := $(call mod_table.get,${3},ref)

    ifeq "$${${1}.ref}" ""
      ${1}.ref := master
    endif
  endif

  ${1}.optional := $(if $(filter true,$(call mod_table.get,${3},optional)),true,false)
endef

mod_package_ref := 1
endif
