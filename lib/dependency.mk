# Functions for dealing with dependencies.
ifneq "${mod_dependency}" "1"

include lib/table.mk

# @brief   Creates a dependency.
# @param1  Prefix for output variables.
# @param2  Name of the dependency.
# @param3  Name of the variable that is a dependency.
# @warning Use with `eval` only.
define mod_dependency.create
    ${1}.name := ${2}

    local.path := $$(call mod_table.get,${3},path)

    ifneq "$${local.path}" ""
        ${1}.type := folder
        ${1}.path := $${local.path}
    else
        local.path := $$(call mod_table.get,${3},git)

        ifneq "$${local.path}" ""
            ${1}.type := git
            ${1}.path := $${local.path}
            ${1}.ref := $$(call mod_table.get,${3},ref)
        else
            $$(error Cannot parse package info for '${2}'.)
        endif
    endif

    ${1}.optional := $$(if $$(filter true,$$(call mod_table.get,${3},optional)),true,false)
endef

# @brief   Downloads the package repository into the package cache.
# @param1  Name of the class instance.
# @warning Use with `eval` only.
define package_ref.download
    local.url := $$(call package_ref.git_url,$${${1}.path_})
    local.repo := $$(call package_ref.repo_cache,${1})

    $$(info Downloading $${${1}.name_} ($${local.url}))
    $$(eval $$(call util.checked_execute,git clone --bare $${local.url} $${local.repo}))
endef

mod_dependency := 1
endif
