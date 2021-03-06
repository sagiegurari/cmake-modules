
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
function(utils_setup_c_test)
  set(oneValueArgs COMPILATION_FLAGS BINARY_DIRECTORY)
  set(multiValueArgs NAME ADDITIONAL_SOURCES)
  cmake_parse_arguments(UTILS_SETUP_C_TEST "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  foreach(TEST_NAME ${UTILS_SETUP_C_TEST_NAME})
    message("Adding Test: ${TEST_NAME}")
    add_executable(test_${TEST_NAME} tests/test_${TEST_NAME}.c ${UTILS_SETUP_C_TEST_ADDITIONAL_SOURCES})
    target_link_libraries(test_${TEST_NAME} ${CMAKE_PROJECT_NAME})
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
function(utils_setup_c_all_tests)
  set(oneValueArgs COMPILATION_FLAGS BINARY_DIRECTORY)
  set(multiValueArgs ADDITIONAL_SOURCES)
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
  )
endfunction(utils_setup_c_all_tests)

