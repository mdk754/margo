# @description Utility functions to supplement make builtins.
ifneq "$(UTIL_MK)" "1"

# @brief   Recursively calls `wildcard` on the subdirectory in param1.
# @param1  Directory to wildcard in, must have a trailing slash.
# @param2  Filename pattern to match against.
define util.recursive_wildcard
$(wildcard $(addsuffix ${2},${1})$(foreach d,$(wildcard $(addsuffix *,${1})),$(call util.recursive_wildcard,${d}/,${2})))
endef

# @brief   Execute a shell command and error out if it returns nonzero.
# @param1  Shell command to execute.
# @warning Use with `eval` only.
define util.checked_execute
    local.return_code := $(shell (${1} 1>/dev/null 2>&1); echo $$?)
    ifneq "$${local.return_code}" "0"
        $$(error Command `${1}` failed with exit code [$${local.return_code}])
    endif
endef

UTIL_MK := 1
endif
