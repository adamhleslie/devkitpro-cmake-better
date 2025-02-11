include_guard(GLOBAL)
# OUT: devkitpro_add_bin2s function adds an object library for converting binary files to object files

devkitpro_find_file(DEVKITPRO_BIN2S "tools/bin/bin2s")

if(DEVKITPRO_BIN2S)
    # Generates assembly and header files from binary files, maintaining the original directory structure
    # If binary_files are relative, they are evaluated based on binary_files_dir
    # If binary_files are absolute, they must be under binary_files_dir
    # If binary_files_dir is relative, CMAKE_CURRENT_SOURCE_DIR will be used as its base directory
    # Extensions in binary file names are appended to the generated file names with an underscore
    # - texture.tpl -> texture_tpl.h / texture_tpl.s
    # If out_dir is relative, CMAKE_CURRENT_BINARY_DIR will be used as its base directory
    function(devkitpro_add_bin2s target binary_files binary_files_dir out_dir)

        devkitpro_make_absolute_if_relative(binary_files_dir ${CMAKE_CURRENT_SOURCE_DIR})
        devkitpro_make_absolute_if_relative(out_dir ${CMAKE_CURRENT_BINARY_DIR})

        # Add a command to process each file with bin2s
        foreach(binary_file IN LISTS binary_files)

            devkitpro_get_relative_and_absolute(${binary_file} ${binary_files_dir} binary_file_relative binary_file_absolute)

            # Compute output files
            cmake_path(HAS_EXTENSION binary_file binary_file_has_extension)
            if(${binary_file_has_extension})
                cmake_path(GET binary_file EXTENSION binary_file_extension)
                string(REPLACE "." "_" out_file_suffix ${binary_file_extension})
                cmake_path(REMOVE_EXTENSION binary_file_relative OUTPUT_VARIABLE binary_file_relative_extensionless)
                cmake_path(APPEND out_file_base ${out_dir} "${binary_file_relative_extensionless}${out_file_suffix}")
            else()
                cmake_path(APPEND out_file_base ${out_dir} ${binary_file_relative})
            endif()

            cmake_path(REPLACE_EXTENSION out_file_base ".h" OUTPUT_VARIABLE out_file_h)
            cmake_path(REPLACE_EXTENSION out_file_base ".s" OUTPUT_VARIABLE out_file_s)

            # Create target directory
            cmake_path(GET out_file_base PARENT_PATH out_file_path)
            file(MAKE_DIRECTORY ${out_file_path})

            # Append to files list
            list(APPEND out_files_h ${out_file_h})
            list(APPEND out_files_s ${out_file_s})

            # Create bin2s command
            add_custom_command(
                    OUTPUT ${out_file_h} ${out_file_s}
                    DEPENDS ${binary_file_absolute}
                    COMMAND ${DEVKITPRO_BIN2S} ARGS -a 32 -H ${out_file_h} ${binary_file_absolute} > ${out_file_s}
            )

        endforeach(binary_file)

        add_library(${target} OBJECT ${out_files_s})
        target_include_directories(${target}
                INTERFACE ${out_dir}
        )
        target_sources(${target}
                INTERFACE
                FILE_SET bin2s
                TYPE HEADERS
                BASE_DIRS ${out_dir}
                FILES ${out_files_h}
        )

        # Log Target Info
        devkitpro_message(VERBOSE ${target})
        get_target_property(include_dirs ${target} INTERFACE_INCLUDE_DIRECTORIES)
        devkitpro_message(VERBOSE "    Include Dirs: ${include_dirs}")
        get_target_property(hfiles ${target} HEADER_SET_bin2s)
        devkitpro_message(VERBOSE "    Headers: ${hfiles}")
        get_target_property(sfiles ${target} SOURCES)
        devkitpro_message(VERBOSE "    Sources: ${sfiles}")

    endfunction(devkitpro_add_bin2s)
endif()
