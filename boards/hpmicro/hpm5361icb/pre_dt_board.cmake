# SPDX-License-Identifier: Apache-2.0

set(SUPPORTED_EMU_PLATFORMS renode)
set(SUPPORT_DIR ${CMAKE_CURRENT_LIST_DIR}/support)

# Suppress "simple_bus_reg" on HPMicro boards as all GPIO ports use the same register.
list(APPEND EXTRA_DTC_FLAGS "-Wno-simple_bus_reg")
