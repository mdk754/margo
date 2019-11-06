# @description A view of the entire package graph from an entrypoint.
ifneq "$(PACKAGE_GRAPH_MK)" "1"

include ${environment.margo_root}package.mk
include ${environment.margo_root}package_ref.mk

# class package_graph {
#   package packages_[]
# }

# @brief   Adds a package to the graph.
# @param1  Name of the class instance.
# @param2  Reference to the package being added.
# @param3  Existing package which depends on the incoming package.
# @warning Use with `eval` only.
define package_graph.add_package
    ifeq "$$(findstring $${${2}.name_},$${${1}.packages_})" ""
        $$(eval $$(call package_ref.fetch,${2}))
        ${1}.packages_ += $${${2}.name_}
        ${1}.packages_.$${${2}.name_}.wanted_by := $${${3}.spec_.name_}
        $$(eval $$(call package.load,${1}.packages_.$${${2}.name_},$$(call package_ref.revision_cache,${2}),false))

        $$(foreach pkg,$${${1}.packages_.$${${2}.name_}.spec_.dependencies_},\
            $$(eval $$(call package_graph.add_package,${1},${1}.packages_.$${${2}.name_}.spec_.dependencies_.$${pkg},${1}.packages_.$${${2}.name_})))
    else
        ${1}.packages_.$${${2}.name_}.wanted_by += $${${3}.spec_.name_}
    endif
endef

# @brief   Creates a package graph.
# @param1  Name of the class instance.
# @param2  Root package instance to generate graph from.
# @warning Use with `eval` only.
define package_graph.create
    $$(foreach pkg,$${${2}.spec_.dependencies_},\
        $$(eval $$(call package_graph.add_package,${1},${2}.spec_.dependencies_.$${pkg},${2})))
endef

PACKAGE_GRAPH_MK := 1
endif
