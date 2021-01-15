# Functions for dealing with inline tables
ifneq "${mod_table}" "1"

include ${margo_path}/lib/util.mk

# @brief   Gets the contents of the table without bracing.
# @param1  Name of the variable that is an inline table.
mod_table.elements = $(filter-out { } {},${${1}})

# @brief   Gets the number of elements in the table.
# @param1  Name of the variable that is an inline table.
mod_table.count = $(shell expr $(words $(call mod_table.elements,${1})) \/ 3)

# @brief   Gets a specific element from the table.
# @param1  Name of the variable that is an inline table.
# @param2  Zero-based index of key value pair to access.
mod_table.at = $(wordlist $(shell expr 0${2} \* 3 + 1),$(shell expr 0${2} \* 3 + 3),$(call mod_table.elements,${1}))

# @brief   Gets the key at a specific position in the table.
# @param1  Name of the variable that is an inline table.
# @param2  Zero-based index of key value pair to access.
mod_table.key_at = $(firstword $(call mod_table.at,${1},${2}))

# @brief   Gets the value at a specific position in the table.
# @param1  Name of the variable that is an inline table.
# @param2  Zero-based index of key value pair to access.
mod_table.value_at = $(subst $("),,$(subst $(,),,$(word 3,$(call mod_table.at,${1},${2}))))

# @brief   Gets the value for a given key in the table.
# @param1  Name of the variable that is an inline table.
# @param2  Key to get value for.
mod_table.get = $(strip $(foreach i,$(shell seq 0 $(shell expr $(call mod_table.count,${1}) - 1)),$(if $(filter ${2},$(call mod_table.key_at,${1},${i})),$(call mod_table.value_at,${1},${i}))))

mod_table := 1
endif
