ifneq "${mod_package_cache}" "1"

include ${margo_path}/lib/package_ref.mk
include ${margo_path}/lib/util.mk

# @brief   Creates a package_cache.
# @param1  Instance prefix.
# @param2  Filesystem path to store repositories in.
# @warning Use with `eval` only.
define mod_package_cache.create
  ifeq "$(wildcard ${2})" ""
    $$(info error: package cache directory `${2}` does not exist.)
    $$(info )
    $$(error Fatal)
  endif

  ${1}.path := ${2}
endef

# @brief   Checkout a package ref.
# @param1  Instance prefix.
# @param2  Ref to package_ref.
# @warning Use with `eval` only.
define mod_package_cache.checkout
  ifneq "${${2}.type}" "git"
    $$(info error: package `${${2}.name}` is not a git repository.)
    $$(info )
    $$(error Fatal)
  endif

  local.git_folder := ${${1}.path}/${${2}.name}/.git
  local.dest_folder := ${${1}.path}/${${2}.name}/${${2}.ref}

  ifeq "$$(wildcard $${local.dest_folder})" ""
    local.rev_parse = $$(shell git -C $${local.git_folder} rev-parse ${${2}.ref}^{commit} 2>/dev/null; echo " $$$$?")

    ifeq "$$(wildcard $${local.git_folder})" ""
      $$(eval $$(call mod_package_cache.download,${1},${${2}.name},${${2}.git}))
    else
      local.url := $$(lastword $$(shell grep url ${${1}.path}/${${2}.name}/.git/config))
      ifneq "$${local.url}" "${${2}.git}"
        $$(info warning: repo url has changed for `${${2}.name} ($${local.url})`)
        $$(shell rm -rf ${${1}.path}/${${2}.name}/.git)
        $$(eval $$(call mod_package_cache.download,${1},${${2}.name},${${2}.git}))
      endif

      local.package_hash := $${local.rev_parse}

      ifneq "$$(lastword $${local.package_hash})" "0"
        $$(eval $$(call mod_package_cache.fetch,${1},${${2}.name}))
      endif
    endif

    local.package_hash := $${local.rev_parse}

    ifneq "$$(lastword $${local.package_hash})" "0"
      $$(info error: commit `${${2}.ref}` does not exist.)
      $$(info )
      $$(error Fatal)
    endif

    local.package_hash := $$(firstword $${local.package_hash})
    ${2}.path := $${local.dest_folder:%${${2}.ref}=%$${local.package_hash}}

    ifeq "$$(wildcard $${${2}.path})" ""
      ifeq "${VERBOSE}" "y"
        $$(info $$(shell printf '     Checking out `${${2}.name}` at `$${local.package_hash}`'))
      endif

      $$(eval $$(call util.checked_execute,git -C $${local.git_folder} archive --format=tar --prefix=$${local.package_hash}/ $${local.package_hash} | tar -C $${local.git_folder:%/.git=%} -xf -))
    endif
  endif
endef

# @brief   Downloads a git repository into the package cache.
# @param1  Instance prefix.
# @param2  Package name.
# @param3  Repository url.
# @warning Use with `eval` only.
define mod_package_cache.download
  $$(info $$(shell printf '  Downloading git repository `${3}`'))
  $$(eval $$(call util.checked_execute,git clone --bare ${3} ${${1}.path}/${2}/.git))
endef

# @brief   Fetch the latest objects and refs from the git remote.
# @param1  Instance prefix.
# @param2  Package name.
# @warning Use with `eval` only.
define mod_package_cache.fetch
  $$(info $$(shell printf '     Updating git repository `$(lastword $(shell grep url ${${1}.path}/${2}/.git/config))`'))
  $$(eval $$(call util.checked_execute,git -C ${${1}.path}/${2}/.git fetch --prune))
endef

mod_package_cache := 1
endif
