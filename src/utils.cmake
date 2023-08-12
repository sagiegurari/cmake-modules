
# Downloads a git repository
#
# Params:
# * URL - Git repo URL
# * REPO_NAME - Git repo name
# * [TAG_NAME] - Optional git tag name
function(utils_git_clone)
  set(oneValueArgs URL REPO_NAME TAG_NAME)
  cmake_parse_arguments(UTILS_GIT_CLONE "" "${oneValueArgs}" "" ${ARGN})

  message(
    "Cloning Git Repository: ${UTILS_GIT_CLONE_REPO_NAME} "
    "URL: ${UTILS_GIT_CLONE_URL} "
    "Tag: ${UTILS_GIT_CLONE_TAG_NAME}"
    )

  execute_process(
    COMMAND git clone ${UTILS_GIT_CLONE_URL}
    )

  if(UTILS_GIT_CLONE_TAG_NAME)
    execute_process(
      COMMAND git checkout tags/${UTILS_GIT_CLONE_TAG_NAME}
      WORKING_DIRECTORY ${UTILS_GIT_CLONE_REPO_NAME}
      )
  endif()
endfunction(utils_git_clone)

# Downloads a git repository
#
# Params:
# * REPO_USERNAME - Github repo user name
# * REPO_NAME - Github repo name
# * [TAG_NAME] - Optional git tag name
function(utils_github_clone_repo)
  set(oneValueArgs REPO_USERNAME REPO_NAME TAG_NAME)
  cmake_parse_arguments(UTILS_GITHUB_CLONE_REPO "" "${oneValueArgs}" "" ${ARGN})

  utils_git_clone(
    URL https://github.com/${UTILS_GITHUB_CLONE_REPO_REPO_USERNAME}/${UTILS_GITHUB_CLONE_REPO_REPO_NAME}.git
    REPO_NAME ${UTILS_GITHUB_CLONE_REPO_REPO_NAME}
    TAG_NAME ${UTILS_GITHUB_CLONE_REPO_TAG_NAME}
    )
endfunction(utils_github_clone_repo)

# Sets variables to an external library.
#
# Params:
# * NAME - Library name
# * PATH - Library path
function(utils_set_standard_external_lib_variables)
  set(oneValueArgs NAME PATH)
  cmake_parse_arguments(UTILS_SET_STANDARD_EXTERNAL_LIB_VARIABLES "" "${oneValueArgs}" "" ${ARGN})

  string(TOUPPER "${UTILS_SET_STANDARD_EXTERNAL_LIB_VARIABLES_NAME}" X_EXTERNAL_LIB_NAME)
  set("X_EXTERNAL_LIB_NAME_ROOT" "${UTILS_SET_STANDARD_EXTERNAL_LIB_VARIABLES_PATH}")
  file(GLOB "X_EXTERNAL_LIB_NAME_SOURCES" "${X_EXTERNAL_LIB_NAME_ROOT}/src/*.c*")
  set("X_EXTERNAL_LIB_NAME_INCLUDE" "${X_EXTERNAL_LIB_NAME_ROOT}/include")

  set("X_EXTERNAL_LIB_NAME" "${X_EXTERNAL_LIB_NAME}" PARENT_SCOPE)
  set("${X_EXTERNAL_LIB_NAME}_ROOT" "${X_EXTERNAL_LIB_NAME_ROOT}" PARENT_SCOPE)
  set("${X_EXTERNAL_LIB_NAME}_SOURCES" "${X_EXTERNAL_LIB_NAME_SOURCES}" PARENT_SCOPE)
  set("${X_EXTERNAL_LIB_NAME}_INCLUDE" "${X_EXTERNAL_LIB_NAME_INCLUDE}" PARENT_SCOPE)
endfunction(utils_set_standard_external_lib_variables)

# Downloads an external repo from github and sets variables to the external
# library source and header directories (if they are structured as expected).
#
# Params:
# * REPO_USERNAME - Github repo user name
# * REPO_NAME - Github repo name
# * [TAG_NAME] - Optional git tag name
# * LIBRARY_NAME - Library name
# * LIBRARY_PARENT_DIRECTORY - Library parent directory
function(utils_add_external_github_lib)
  set(oneValueArgs REPO_USERNAME REPO_NAME TAG_NAME LIBRARY_NAME LIBRARY_PARENT_DIRECTORY)
  cmake_parse_arguments(UTILS_ADD_EXTERNAL_GITHUB_LIB "" "${oneValueArgs}" "" ${ARGN})

  message(
    "Adding External Library: ${UTILS_ADD_EXTERNAL_GITHUB_LIB_LIBRARY_NAME} "
    "Github Repostiory: ${UTILS_ADD_EXTERNAL_GITHUB_LIB_REPO_USERNAME}/${UTILS_ADD_EXTERNAL_GITHUB_LIB_REPO_NAME} "
    "Tag: ${UTILS_ADD_EXTERNAL_GITHUB_LIB_TAG_NAME}"
    )

  utils_github_clone_repo(
    REPO_USERNAME ${UTILS_ADD_EXTERNAL_GITHUB_LIB_REPO_USERNAME}
    REPO_NAME ${UTILS_ADD_EXTERNAL_GITHUB_LIB_REPO_NAME}
    TAG_NAME ${UTILS_ADD_EXTERNAL_GITHUB_LIB_TAG_NAME}
    )

  utils_set_standard_external_lib_variables(
    NAME ${UTILS_ADD_EXTERNAL_GITHUB_LIB_LIBRARY_NAME}
    PATH "${UTILS_ADD_EXTERNAL_GITHUB_LIB_LIBRARY_PARENT_DIRECTORY}/${UTILS_ADD_EXTERNAL_GITHUB_LIB_REPO_NAME}"
    )
  # proxy variables
  set("${X_EXTERNAL_LIB_NAME}_ROOT" "${${X_EXTERNAL_LIB_NAME}_ROOT}" PARENT_SCOPE)
  set("${X_EXTERNAL_LIB_NAME}_SOURCES" "${${X_EXTERNAL_LIB_NAME}_SOURCES}" PARENT_SCOPE)
  set("${X_EXTERNAL_LIB_NAME}_INCLUDE" "${${X_EXTERNAL_LIB_NAME}_INCLUDE}" PARENT_SCOPE)

  message("External Library Variables:")
  message("${X_EXTERNAL_LIB_NAME}_ROOT ${X_EXTERNAL_LIB_NAME_ROOT}")
  message("${X_EXTERNAL_LIB_NAME}_SOURCES ${X_EXTERNAL_LIB_NAME_SOURCES}")
  message("${X_EXTERNAL_LIB_NAME}_INCLUDE ${X_EXTERNAL_LIB_NAME_INCLUDE}")
endfunction(utils_add_external_github_lib)

# Adds a test target/s with the given name/s.
# Tests are expected to be located at the tests directory and should be named
# as "test_<test name>.c"
# In addition, the CMAKE_PROJECT_NAME variable is expected to be defined.
#
# Params:
# * NAME - Test name/s
# * ADDITIONAL_SOURCES - Additional test sources
# * COMPILATION_FLAGS - Compliation flags
# * BINARY_DIRECTORY - Binary directory
# * LIBRARIES - Additional test libraries
function(utils_setup_c_test)
  set(oneValueArgs COMPILATION_FLAGS BINARY_DIRECTORY)
  set(multiValueArgs NAME ADDITIONAL_SOURCES LIBRARIES)
  cmake_parse_arguments(UTILS_SETUP_C_TEST "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  foreach(TEST_NAME ${UTILS_SETUP_C_TEST_NAME})
    message("Adding Test: ${TEST_NAME}")
    add_executable(test_${TEST_NAME} tests/test_${TEST_NAME}.c ${UTILS_SETUP_C_TEST_ADDITIONAL_SOURCES})
    target_link_libraries(test_${TEST_NAME} ${CMAKE_PROJECT_NAME} ${UTILS_SETUP_C_TEST_LIBRARIES})
    set_target_properties(
      test_${TEST_NAME}
      PROPERTIES COMPILE_FLAGS "${UTILS_SETUP_C_TEST_COMPILATION_FLAGS}"
      )
    add_test(
      NAME ${TEST_NAME}
      WORKING_DIRECTORY ${UTILS_SETUP_C_TEST_BINARY_DIRECTORY}
      COMMAND test_${TEST_NAME}
      )
  endforeach(TEST_NAME)
endfunction(utils_setup_c_test)

# Adds test targets for all test files found under the tests directory.
# Tests are expected to be located at the tests directory and should be named
# as "test_<test name>.c"
# In addition, the CMAKE_PROJECT_NAME variable is expected to be defined.
#
# Params:
# * ADDITIONAL_SOURCES - Additional test sources
# * COMPILATION_FLAGS - Compliation flags
# * BINARY_DIRECTORY - Binary directory
# * LIBRARIES - Additional test libraries
function(utils_setup_c_all_tests)
  set(oneValueArgs COMPILATION_FLAGS BINARY_DIRECTORY)
  set(multiValueArgs ADDITIONAL_SOURCES LIBRARIES)
  cmake_parse_arguments(UTILS_SETUP_C_ALL_TESTS "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  file(
    GLOB TEST_FILES
    LIST_DIRECTORIES false
    ./tests/test_*.c
    )

  foreach(TEST_NAME ${TEST_FILES})
    string(REGEX REPLACE ".*/tests/test_" "" TEST_NAME ${TEST_NAME})
    string(REGEX REPLACE "\\.c" "" TEST_NAME ${TEST_NAME})

    list(APPEND TEST_NAMES ${TEST_NAME})
  endforeach(TEST_NAME)

  message("Found Tests: ${TEST_NAMES}")

  utils_setup_c_test(
    NAME ${TEST_NAMES}
    ADDITIONAL_SOURCES "${UTILS_SETUP_C_ALL_TESTS_ADDITIONAL_SOURCES}"
    COMPILATION_FLAGS "${UTILS_SETUP_C_ALL_TESTS_COMPILATION_FLAGS}"
    BINARY_DIRECTORY "${UTILS_SETUP_C_ALL_TESTS_BINARY_DIRECTORY}"
    LIBRARIES ${UTILS_SETUP_C_ALL_TESTS_LIBRARIES}
    )
endfunction(utils_setup_c_all_tests)

# Adds test targets for all test files found under the tests directory.
# Tests are expected to be located at the tests directory and should be named
# as "test_<test name>.c"
# In addition, the CMAKE_PROJECT_NAME variable is expected to be defined.
#
# Params:
# * SOURCES - Test sources
# * COMPILATION_FLAGS - Compliation flags
function(utils_setup_test_lib)
  set(oneValueArgs COMPILATION_FLAGS)
  set(multiValueArgs SOURCES)
  cmake_parse_arguments(UTILS_SETUP_TEST_LIB "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  add_library("Test" STATIC ${UTILS_SETUP_TEST_LIB_SOURCES})
  target_link_libraries("Test" ${CMAKE_PROJECT_NAME})
  set_target_properties(
    "Test"
    PROPERTIES COMPILE_FLAGS "${UTILS_SETUP_TEST_LIB_COMPILATION_FLAGS}"
    )
endfunction(utils_setup_test_lib)

# Adds linter target.
#
# Params:
# * INCLUDE_DIRECTORY
# * SOURCES - The sources to check
# * WORKING_DIRECTORY
# * [ALL] - FALSE for not ALL, otherwise any value (including undefined) is by default ALL
function(utils_cppcheck)
  set(oneValueArgs INCLUDE_DIRECTORY WORKING_DIRECTORY ALL)
  set(multiValueArgs SOURCES)
  cmake_parse_arguments(UTILS_CPPCHECK "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  find_program(CMAKE_CXX_CPPCHECK NAMES cppcheck)

  if (CMAKE_CXX_CPPCHECK)
    if ("${UTILS_CPPCHECK_ALL}" STREQUAL "FALSE")
      set(ALL)
    else()
      set(ALL ALL)
    endif()

    add_custom_target(cppcheck ${ALL}
      ${CMAKE_CXX_CPPCHECK}
      --enable=all --inline-suppr --error-exitcode=1 --suppress=missingIncludeSystem -I ${UTILS_CPPCHECK_INCLUDE_DIRECTORY} ${UTILS_CPPCHECK_SOURCES}
      WORKING_DIRECTORY "${UTILS_CPPCHECK_WORKING_DIRECTORY}")
  endif()
endfunction(utils_cppcheck)

# Adds formatter target.
#
# Params:
# * CONFIG_FILE - The uncrustify cfg
# * SOURCES - The sources to format
# * [ALL] - FALSE for not ALL, otherwise any value (including undefined) is by default ALL
function(utils_uncrustify)
  set(oneValueArgs CONFIG_FILE ALL)
  set(multiValueArgs SOURCES)
  cmake_parse_arguments(UTILS_UNCRUSTIFY "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  find_program(CMAKE_CXX_UNCRUSTIFY NAMES uncrustify)

  if (CMAKE_CXX_UNCRUSTIFY)
    if ("${UTILS_UNCRUSTIFY_ALL}" STREQUAL "FALSE")
      set(ALL)
    else()
      set(ALL ALL)
    endif()

    add_custom_target(uncrustify ${ALL}
      uncrustify
      -c ${UTILS_UNCRUSTIFY_CONFIG_FILE}
      --no-backup ${UTILS_UNCRUSTIFY_SOURCES})
  endif()
endfunction(utils_uncrustify)

# Increments the build file (or creates a new one is
# does not exist) and sets the variable to the new value.
# This can be wrapped via add_custom_command to a standalone cmake
# file that can trigger this function.
#
# Params:
# * BUILD_NUMBER_FILE - The path to the build number file
# * NAME - The variable name to hold the new build number
function(utils_build_file_increment)
  set(oneValueArgs BUILD_NUMBER_FILE NAME)
  cmake_parse_arguments(UTILS_BUILD_FILE_INCREMENT "" "${oneValueArgs}" "" ${ARGN})

  if(EXISTS ${UTILS_BUILD_FILE_INCREMENT_BUILD_NUMBER_FILE})
    file(READ ${UTILS_BUILD_FILE_INCREMENT_BUILD_NUMBER_FILE} BUILD_NUMBER)
    math(EXPR BUILD_NUMBER "${BUILD_NUMBER}+1")
  else()
    set(BUILD_NUMBER "1")
  endif()

  message("Build Number: ${BUILD_NUMBER}")

  file(WRITE ${UTILS_BUILD_FILE_INCREMENT_BUILD_NUMBER_FILE} "${BUILD_NUMBER}")

  set("${UTILS_BUILD_FILE_INCREMENT_NAME}" "${BUILD_NUMBER}" PARENT_SCOPE)
endfunction(utils_build_file_increment)

# Runs xxd on the given file to generate a C header content,
# wraps it with header macros and writes it to a file.
#
# Params:
# * INPUT_RAW_FILE - The input file to invoke the xxd on
# * OUTPUT_HEADER_FILE - The output header file that will hold the generated content
# * HEADER_NAME - Used in the header def macro
# * ROOT_DIRECTORY - Used to get relative path to output file which impacts header content
function(utils_xxd)
  set(oneValueArgs INPUT_RAW_FILE OUTPUT_HEADER_FILE HEADER_NAME ROOT_DIRECTORY)
  cmake_parse_arguments(UTILS_XXD "" "${oneValueArgs}" "" ${ARGN})

  get_filename_component(ROOT_DIRECTORY "${UTILS_XXD_ROOT_DIRECTORY}" ABSOLUTE)
  file(RELATIVE_PATH INPUT_RAW_FILE "${ROOT_DIRECTORY}" "${UTILS_XXD_INPUT_RAW_FILE}")

  message("Running xxd for file: ${INPUT_RAW_FILE}")

  execute_process(
    COMMAND "xxd" "-i" "${INPUT_RAW_FILE}"
    WORKING_DIRECTORY "${ROOT_DIRECTORY}"
    OUTPUT_VARIABLE HEADER_CONTENT
    COMMAND_ERROR_IS_FATAL ANY
    )

  set(HEADER_CONTENT "#ifndef ${UTILS_XXD_HEADER_NAME}_H\n#define ${UTILS_XXD_HEADER_NAME}_H\n${HEADER_CONTENT}\n#endif\n")

  if(EXISTS ${UTILS_XXD_OUTPUT_HEADER_FILE})
    file(READ ${UTILS_XXD_OUTPUT_HEADER_FILE} OLD_HEADER_CONTENT)
    if (NOT "${HEADER_CONTENT}" STREQUAL "${OLD_HEADER_CONTENT}")
      file(WRITE ${UTILS_XXD_OUTPUT_HEADER_FILE} "${HEADER_CONTENT}")
    endif()
  else()
    file(WRITE ${UTILS_XXD_OUTPUT_HEADER_FILE} "${HEADER_CONTENT}")
  endif()

  message(
    "Created Header File: ${UTILS_XXD_OUTPUT_HEADER_FILE}\n"
    "Content:\n${HEADER_CONTENT}"
    )
endfunction(utils_xxd)

# Runs xxd on all provided files and generate a C header file for them.
#
# Params:
# * INPUT_RAW_FILES - All files to run xxd on
# * ROOT_DIRECTORY - Used to get relative path to output file which impacts header content
function(utils_xxd_all)
  set(oneValueArgs ROOT_DIRECTORY)
  set(multiValueArgs INPUT_RAW_FILES)
  cmake_parse_arguments(UTILS_XXD_ALL "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  foreach(INPUT_RAW_FILE ${UTILS_XXD_ALL_INPUT_RAW_FILES})
    get_filename_component(OUTPUT_DIRECTORY ${INPUT_RAW_FILE} DIRECTORY)
    get_filename_component(BASE_FILENAME ${INPUT_RAW_FILE} NAME_WLE)
    set(OUTPUT_HEADER_FILE "${OUTPUT_DIRECTORY}/${BASE_FILENAME}_resource_template.h")
    string(TOUPPER "${BASE_FILENAME}_resource_template" HEADER_NAME)

    message(
      "XXD Args\n"
      "Raw File: ${INPUT_RAW_FILE}\n"
      "Output Header File: ${OUTPUT_HEADER_FILE}\n"
      "Header Name: ${HEADER_NAME}\n"
      "Root Directory: ${UTILS_XXD_ALL_ROOT_DIRECTORY}"
      )

    utils_xxd(
      INPUT_RAW_FILE "${INPUT_RAW_FILE}"
      OUTPUT_HEADER_FILE "${OUTPUT_HEADER_FILE}"
      HEADER_NAME "${HEADER_NAME}"
      ROOT_DIRECTORY "${UTILS_XXD_ALL_ROOT_DIRECTORY}"
      )
  endforeach(INPUT_RAW_FILE)
endfunction(utils_xxd_all)

