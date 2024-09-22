include_guard(GLOBAL)
# OUT: Static libraries for each libogc component of the form devkitpro::libogc::gamecube::X and devkitpro::libogc::wii::X

# Helper function used for importing
function(devkitpro_libogc_import lib_name is_cube_lib is_wii_lib)
    if(${is_cube_lib})
        devkitpro_message(CHECK_START "Importing ${lib_name} (Gamecube)")
        cmake_path(APPEND cube_lib_location "libogc/lib/cube" "lib${lib_name}.a")
        cmake_path(ABSOLUTE_PATH cube_lib_location BASE_DIRECTORY ${DEVKITPRO})
        if(EXISTS ${cube_lib_location})
            add_library(devkitpro::libogc::gamecube::${lib_name} STATIC IMPORTED)
            set_target_properties(devkitpro::libogc::gamecube::${lib_name} PROPERTIES
                    IMPORTED_LOCATION ${cube_lib_location}
            )
            target_include_directories(devkitpro::libogc::gamecube::${lib_name} INTERFACE "${DEVKITPRO}/libogc/include")
            devkitpro_message(CHECK_PASS "Imported")
        else()
            devkitpro_message(CHECK_FAIL "Could not find at ${cube_lib_location}")
            set(libogc_import_failed TRUE PARENT_SCOPE)
        endif()
    endif()

    if(${is_wii_lib})
        devkitpro_message(CHECK_START "Importing ${lib_name} (Wii)")
        cmake_path(APPEND wii_lib_location "libogc/lib/wii" "lib${lib_name}.a")
        cmake_path(ABSOLUTE_PATH wii_lib_location BASE_DIRECTORY ${DEVKITPRO})
        if(EXISTS ${wii_lib_location})
            add_library(devkitpro::libogc::wii::${lib_name} STATIC IMPORTED)
            set_target_properties(devkitpro::libogc::wii::${lib_name} PROPERTIES
                    IMPORTED_LOCATION ${wii_lib_location}
            )
            target_include_directories(devkitpro::libogc::wii::${lib_name} INTERFACE "${DEVKITPRO}/libogc/include")
            devkitpro_message(CHECK_PASS "Imported")
        else()
            devkitpro_message(CHECK_FAIL "Could not find at ${wii_lib_location}")
            set(libogc_import_failed TRUE PARENT_SCOPE)
        endif()
    endif()
endfunction(devkitpro_libogc_import)

set(libogc_import_failed FALSE)
devkitpro_message(CHECK_START "Importing libogc")
list(APPEND CMAKE_MESSAGE_INDENT "  ")

devkitpro_libogc_import(aesnd       TRUE  TRUE)
devkitpro_libogc_import(asnd        TRUE  TRUE)
devkitpro_libogc_import(bba         TRUE  FALSE)
devkitpro_libogc_import(bte         FALSE TRUE)
devkitpro_libogc_import(db          TRUE  TRUE)
devkitpro_libogc_import(di          FALSE TRUE)
devkitpro_libogc_import(fat         TRUE  TRUE)
devkitpro_libogc_import(gxflux      TRUE  TRUE)
devkitpro_libogc_import(iso9660     TRUE  TRUE)
devkitpro_libogc_import(mad         TRUE  TRUE)
devkitpro_libogc_import(modplay     TRUE  TRUE)
devkitpro_libogc_import(ogc         TRUE  TRUE)
devkitpro_libogc_import(tinysmb     TRUE  TRUE)
devkitpro_libogc_import(wiikeyboard FALSE TRUE)
devkitpro_libogc_import(wiiuse      FALSE TRUE)

list(POP_BACK CMAKE_MESSAGE_INDENT)
if(${libogc_import_failed})
    devkitpro_message(CHECK_FAIL "Missing components")
    message(FATAL_ERROR)
else()
    devkitpro_message(CHECK_PASS "Imported all components")
endif()
