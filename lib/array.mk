# Functions for dealing with inline arrays
ifneq "${mod_array}" "1"

local.comma:=,
local.quote:="

# @brief   Gets the contents of the array without bracing.
# @param1  Name of the variable that is an inline array.
mod_array.elements = $(filter-out [ ] [],${${1}})

# @brief   Gets the number of elements in the array.
# @param1  Name of the variable that is an inline array.
mod_array.count = $(words $(call mod_array.elements,${1}))

# @brief   Gets a specific element from the array.
# @param1  Name of the variable that is an inline array.
# @param2  Zero-based index of the element.
mod_array.at = $(strip $(subst $(local.quote),,$(subst $(local.comma),,$(word $(shell expr 0${2} + 1),$(call mod_array.elements,${1})))))

mod_array := 1
endif
