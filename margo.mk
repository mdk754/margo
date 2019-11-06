environment.margo_root := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
environment.margo_home := ${HOME}/.margo/
environment.package_cache := ${environment.margo_home}packages

include ${environment.margo_root}entrypoint.mk
include ${environment.margo_root}package_graph.mk

$(eval $(call entrypoint.create,margo.entrypoint,$(CURDIR)))
$(eval $(call package_graph.create,margo.entrypoint.graph_,margo.entrypoint.root_))

$(foreach line,$(sort $(filter margo.%,$(.VARIABLES))),$(info $(line) = $($(line))))
