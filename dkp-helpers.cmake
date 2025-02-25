include_guard(GLOBAL)

macro(dkp_message level msg)
    if(${level} STREQUAL "CHECK_PASS" OR ${level} STREQUAL "CHECK_FAIL")
        message(${level} "${msg}")
    else()
        message(${level} "[devkitPro] ${msg}")
    endif()
endmacro()

# TODO: Should we use find_program? We know the path directly...
function(dkp_find_file variable file_path_relative)
    cmake_path(GET file_path_relative STEM file_stem)
    dkp_message(CHECK_START "Finding ${file_stem}")
    if(DEFINED ${variable})
        if(EXISTS ${${variable}})
            dkp_message(CHECK_PASS "Using location from CMake variable ${variable}: ${${variable}}")
        else()
            dkp_message(CHECK_FAIL "Invalid location from CMake variable ${variable}: ${${variable}}")
            dkp_message(FATAL_ERROR "Invalid location from CMake variable ${variable}: ${${variable}}")
        endif()
    elseif(DEFINED ENV{${variable}})
        if(EXISTS $ENV{${variable}})
            set(${variable} $ENV{${variable}} PARENT_SCOPE)
            dkp_message(CHECK_PASS "Using location from environment variable ${variable}: $ENV{${variable}}")
        else()
            dkp_message(CHECK_FAIL "Invalid location from environment variable ${variable}: $ENV{${variable}}")
            dkp_message(FATAL_ERROR "Invalid location from environment variable ${variable}: $ENV{${variable}}")
        endif()
    else()
        if(NOT DEVKITPRO)
            dkp_message(CHECK_FAIL "DEVKITPRO must be defined")
            dkp_message(FATAL_ERROR "DEVKITPRO must be defined")
        endif()
        cmake_path(ABSOLUTE_PATH file_path_relative BASE_DIRECTORY ${DEVKITPRO} OUTPUT_VARIABLE file_path_absolute)
        if(EXISTS ${file_path_absolute})
            set(${variable} ${file_path_absolute} PARENT_SCOPE)
            dkp_message(CHECK_PASS "Found ${file_path_absolute}")
        else()
            dkp_message(CHECK_FAIL "Not at expected location ${file_path_absolute}")
            dkp_message(FATAL_ERROR "Not at expected location ${file_path_absolute}")
        endif()
    endif()
endfunction(dkp_find_file)

function(dkp_get_relative_and_absolute path base_directory relative_path_variable absolute_path_variable)
    cmake_path(IS_ABSOLUTE path path_is_absolute)
    if(${path_is_absolute})
        cmake_path(IS_PREFIX base_directory ${path} is_prefix)
        if(NOT ${is_prefix})
            dkp_message(FATAL_ERROR "Base directory \"${base_directory}\" is not a prefix for path \"${path}\"")
        endif()

        cmake_path(SET absolute_path ${path})
        cmake_path(RELATIVE_PATH path BASE_DIRECTORY ${base_directory} OUTPUT_VARIABLE relative_path)
    else()
        cmake_path(SET relative_path ${path})
        cmake_path(ABSOLUTE_PATH relative_path BASE_DIRECTORY ${base_directory} OUTPUT_VARIABLE absolute_path)
    endif()

    set(${absolute_path_variable} ${absolute_path} PARENT_SCOPE)
    set(${relative_path_variable} ${relative_path} PARENT_SCOPE)
endfunction(dkp_get_relative_and_absolute)

function(dkp_make_absolute_if_relative path_variable default_base_directory)
    cmake_path(IS_ABSOLUTE ${path_variable} is_absolute)
    if(${is_absolute})
        cmake_path(SET absolute_path ${${path_variable}})
    else()
        cmake_path(ABSOLUTE_PATH ${path_variable} BASE_DIRECTORY ${default_base_directory} OUTPUT_VARIABLE absolute_path)
    endif()

    set(${path_variable} ${absolute_path} PARENT_SCOPE)
endfunction(dkp_make_absolute_if_relative)
