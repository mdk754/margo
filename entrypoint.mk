# @description The context surrounding the package root.
ifneq "$(ENTRYPOINT_MK)" "1"

include ${environment.margo_root}package.mk
include ${environment.margo_root}package_graph.mk
include ${environment.margo_root}package_ref.mk

# class entrypoint {
#   package root_
#   lockfile lock_
#   package_graph graph_
# }

# @brief   Creates an entrypoint instance.
# @param1  Name of the class instance.
# @param2  Directory of the root package.
# @warning Use with `eval` only.
define entrypoint.create
    $$(eval $$(call package.load,${1}.root_,${2},true))
endef

# @brief   Gets all dependencies of the root package.
# @param1  Name of the class instance.
# @warning Use with `eval` only.
# define entrypoint.acquire_dependencies
#     $$(foreach dep,$${${1}.root_.spec_.dependencies_},\
#         $$(eval $$(call package_ref.fetch,${1}.root_.spec_.dependencies_.$${dep})))
# endef

ENTRYPOINT_MK := 1
endif
