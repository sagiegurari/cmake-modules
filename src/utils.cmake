
# Downloads a git repository
#
# Params:
# * Git repo URL
# * Git repo name
# * Git tag name
macro(utils_git_clone)
  message("Cloning Git Repository: ${ARGV1} URL: ${ARGV0} Tag: ${ARGV2}")
  execute_process(
    COMMAND git clone ${ARGV0}
  )
  execute_process(
    COMMAND git checkout tags/${ARGV2}
    WORKING_DIRECTORY ${ARGV1}
  )
endmacro(utils_git_clone)

# Downloads a git repository
#
# Params:
# * Github repo user name
# * Github repo name
# * Git tag name
macro(utils_github_clone_repo)
  utils_git_clone(https://github.com/${ARGV0}/${ARGV1}.git ${ARGV1} ${ARGV2})
endmacro(utils_github_clone_repo)

# Sets variables to an external library.
#
# Params:
# * Library name
# * Library path
macro(utils_set_standard_external_lib_variables)
  string(TOUPPER ${ARGV0} X_EXTERNAL_LIB_NAME)
  set("${X_EXTERNAL_LIB_NAME}_ROOT" "${ARGV1}")
  file(GLOB "${X_EXTERNAL_LIB_NAME}_SOURCES" "${${X_EXTERNAL_LIB_NAME}_ROOT}/src/*.c*")
  set("${X_EXTERNAL_LIB_NAME}_INCLUDE" "${${X_EXTERNAL_LIB_NAME}_ROOT}/include")

  message("New defined variables:")
  message("${X_EXTERNAL_LIB_NAME}_ROOT ${${X_EXTERNAL_LIB_NAME}_ROOT}")
  message("${X_EXTERNAL_LIB_NAME}_SOURCES ${${X_EXTERNAL_LIB_NAME}_SOURCES}")
  message("${X_EXTERNAL_LIB_NAME}_INCLUDE ${${X_EXTERNAL_LIB_NAME}_INCLUDE}")
endmacro()

# Downloads an external repo from github and sets variables to the external
# library source and header directories (if they are structured as expected).
#
# Params:
# * Github repo user name
# * Github repo name
# * Git tag name
# * Library name
# * Library parent directory
macro(utils_add_external_github_lib)
  message("Adding External Library: ${ARGV3} Github Repostiory: ${ARGV0}/${ARGV1} Tag: ${ARGV2}")
  utils_github_clone_repo(${ARGV0} ${ARGV1} ${ARGV2})
  utils_set_standard_external_lib_variables(${ARGV3} "${ARGV4}/${ARGV1}")
endmacro(utils_add_external_github_lib)

# Adds a test target with the given name.
# Tests are expected to be located at the tests directory and should be named
# as "test_<test name>.c"
# In addition, the CMAKE_PROJECT_NAME variable is expected to be defined.
#
# Params:
# * Test name
# * Additional test sources
# * Compliation flags
# * Binary directory
macro(utils_setup_c_test)
  message("Adding Test: ${ARGV0}")
  add_executable(test_${ARGV0} tests/test_${ARGV0}.c ${ARGV1})
  target_link_libraries(test_${ARGV0} ${CMAKE_PROJECT_NAME})
  set_target_properties(test_${ARGV0} PROPERTIES COMPILE_FLAGS "${ARGV2}")
  add_test(NAME ${ARGV0}
    WORKING_DIRECTORY ${ARGV3}
    COMMAND test_${ARGV0})
endmacro(utils_setup_c_test)

