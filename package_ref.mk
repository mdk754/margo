# @description A reference to a named and versioned codebase.
ifneq "$(PACKAGE_REF_MK)" "1"

include ${environment.margo_root}util.mk

# class package_ref {
#   string name_
#   string type_
#   string path_
# }

# @brief   Creates a reference to a package.
# @param1  Name of the class instance.
# @param2  Name of the package.
# @param3  Source of the package.
# @warning Use with `eval` only.
define package_ref.create
    ${1}.name_ := ${2}

    local.source_type := $$(firstword $$(subst |, ,${3}))

    ifeq "$${local.source_type}" "git"
        ${1}.type_ := git
    else
        ifeq "$${local.source_type}" "filesystem"
            ${1}.type_ := filesystem
        else
            $$(error Cannot understand package path '${3}'. Must specify 'git|<url>@<branch/tag/revision>' or 'filesystem|<path>' location.)
        endif
    endif

    ${1}.path_ := ${3}
    ${1}.path_ := $${${1}.path_:$${local.source_type}|%=%}
endef

define package_ref.git_revision
$(lastword $(subst @, ,${1}))
endef

define package_ref.git_url
${1:%@$(call package_ref.git_revision,${1})=%}
endef

# @brief   Returns the path where the repo would be in the package cache.
# @param1  Name of the class instance.
define package_ref.repo_cache
${environment.package_cache}/${${1}.name_}/.git
endef

# @brief   Returns the path where the ref would be in the package cache.
# @param1  Name of the class instance.
define package_ref.revision_cache
${environment.package_cache}/${${1}.name_}/$(call package_ref.git_revision,${${1}.path_})
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

# @brief   Updates the package repository in the package cache.
# @param1  Name of the target package.
# @warning Use with `eval` only.
define package_ref.update
    local.url := $$(call package_ref.git_url,$${${1}.path_})
    local.repo := $$(call package_ref.repo_cache,${1})

    $$(info Updating $(1) ($${local.url}))
    $$(eval $$(call util.checked_execute,git -C $${local.repo} fetch --prune))
endef

# @brief   Fetches a package from its repository.
# @param1  Name of the class instance.
# @warning Use with `eval` only.
define package_ref.fetch
    ifeq "$${${1}.type_}" "git"
        local.package_revision := $$(call package_ref.git_revision,$${${1}.path_})
        local.package_path := $${environment.package_cache}/$${${1}.name_}/$${local.package_revision}
        local.package_repo := $${environment.package_cache}/$${${1}.name_}/.git
        local.fetch_command = $$(shell git -C $${local.package_repo} rev-parse $${local.package_revision}^{commit} 2>/dev/null; echo " $$$$?")

        # If the ref isn't in the cache yet, let's get it there.
        ifeq "$$(wildcard $${local.package_path})" ""
            # If the git repo isn't in the cache yet, download it.
            ifeq "$$(wildcard $${local.package_repo})" ""
                $$(eval $$(call package_ref.download,${1}))
            else
                local.package_hash := $${local.fetch_command}

                # Only fetch if we didn't already have the ref available.
                ifneq "$$(lastword $${local.package_hash})" "0"
                    $$(eval $$(call package_ref.update,${1}))
                endif
            endif

            local.package_hash := $${local.fetch_command}

            # If we can't find the ref after a clone or fetch, it must not exist.
            ifneq "$$(lastword $${local.package_hash})" "0"
                $$(error Repository does not contain a commit with hash `$${local.package_revision}`)
            endif

            local.package_hash := $$(firstword $${local.package_hash})
            ${1}.path_ := $${${1}.path_:%$${local.package_revision}=%$${local.package_hash}}
            local.package_path := $${local.package_path:%$${local.package_revision}=%$${local.package_hash}}

            # If the path didn't exist originally because it was a branch name, skip
            # the sync if it exists now.
            ifeq "$$(wildcard $${local.package_path})" ""
                $$(info Syncing $${${1}.name_} ($${local.package_hash}))
                $$(eval $$(call util.checked_execute,git -C $${local.package_repo} archive --format=tar --prefix=$${local.package_hash}/ $${local.package_hash} | tar xf - --directory $${local.package_repo:%/.git=%}))
            endif
        endif
    else
        $$(error Asked to fetch package '${1}.name_', but it is not a git repository.)
    endif
endef

PACKAGE_REF_MK := 1
endif
