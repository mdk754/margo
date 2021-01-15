ifneq "${mod_package_graph}" "1"

include ${margo_path}/lib/manifest.mk
include ${margo_path}/lib/package.mk
include ${margo_path}/lib/package_cache.mk
include ${margo_path}/lib/package_ref.mk

# @brief   Creates a package_graph.
# @param1  Instance prefix.
# @param2  Ref to the package_ref of the root project.
# @param3  Filesystem path to store repositories in.
# @warning Use with `eval` only.
define mod_package_graph.create
  ${1}.packages :=
  $$(eval $$(call mod_package_cache.create,${1}.cache,${3}))
  $$(eval $$(call mod_package_graph.add,${1},${2}))
  ${1}.root := ${${2}.name}
endef

# @brief   Adds a package to the graph.
# @param1  Instance prefix.
# @param2  Ref to package_ref being added.
# @param3  Name of package which is requesting the addition.
# @warning Use with `eval` only.
define mod_package_graph.add
  ifeq "${${2}.type}" "git"
    $$(eval $$(call mod_package_cache.checkout,${1}.cache,${2}))
  else
    ifeq "$(wildcard ${${2}.path})" ""
      $$(info error: invalid package path for `${${2}.name} (${${2}.path})`.)
      $$(info )
      $$(error Fatal)
    endif
  endif

  ifeq "$(findstring ${${2}.name},${${1}.packages})" ""
    ${1}.packages := $$(strip ${${1}.packages} ${${2}.name})
    $$(eval $$(call mod_package.load,${1}.packages.${${2}.name},$${${2}.path}))
    ${1}.packages.${${2}.name}.wanted_by := $$(strip $${${1}.packages.${${2}.name}.wanted_by} ${3})
    $$(foreach dep,$${${1}.packages.${${2}.name}.manifest.dependencies},$$(eval $$(call mod_package_graph.add,${1},${1}.packages.${${2}.name}.manifest.dependencies.$${dep},${${2}.name})))
  else
    $$(eval $$(call mod_manifest.version,$${${2}.path}/manifest,local.incoming_version))

    ifneq "$${local.incoming_version}" "$${${1}.packages.${${2}.name}.manifest.version}"
      $$(info error: failed to select a version for `${${2}.name}`.)
      $$(info $$(shell printf '    ... required by package `${3} v$${${1}.packages.${3}.manifest.version}`'))

      ifneq "$${${1}.packages.${3}.wanted_by}" ""
        $$(info $$(shell printf '    ... which is depended on by `$$(firstword $${${1}.packages.${3}.wanted_by}) v$${${1}.packages.$$(firstword $${${1}.packages.${3}.wanted_by}).manifest.version}`'))

        ifneq "$$(words $${${1}.packages.${3}.wanted_by})" "1"
          $$(foreach dep,$$(wordlist 2,$$(words $${${1}.packages.${3}.wanted_by}),$${${1}.packages.${3}.wanted_by}),$$(info $$(shell printf '      ... as well as `$${dep} v$${${1}.packages.$${dep}.manifest.version}`')))
        endif
      endif

      $$(info version required is: $${local.incoming_version})

      $$(info )
      $$(info this version conflicts with the previously selected package.)
      $$(info )
      $$(info $$(shell printf '  previously selected package `${${2}.name} v$${${1}.packages.${${2}.name}.manifest.version}`'))
      $$(info $$(shell printf '    ... which is depended on by `$$(firstword $${${1}.packages.${${2}.name}.wanted_by}) v$${${1}.packages.$$(firstword $${${1}.packages.${${2}.name}.wanted_by}).manifest.version}`'))

      ifneq "$$(words $${${1}.packages.${${2}.name}.wanted_by})" "1"
        $$(foreach dep,$$(wordlist 2,$$(words $${${1}.packages.${${2}.name}.wanted_by}),$${${1}.packages.${${2}.name}.wanted_by}),$$(info $$(shell printf '      ... as well as `$${dep} v$${${1}.packages.$${dep}.manifest.version}`')))
      endif

      $$(info )
      $$(error Fatal)
    endif

    ${1}.packages.${${2}.name}.wanted_by := $$(strip $${${1}.packages.${${2}.name}.wanted_by} ${3})
  endif
endef

mod_package_graph := 1
endif
