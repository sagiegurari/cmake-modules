# cmake-modules

[![Release](https://img.shields.io/github/v/release/sagiegurari/cmake-modules)](https://github.com/sagiegurari/cmake-modules/releases)
[![license](https://img.shields.io/github/license/sagiegurari/cmake-modules)](https://github.com/sagiegurari/cmake-modules/blob/master/LICENSE)

> Reusable cmake utilities for C projects.

* [Overview](#overview)
* [Usage](#usage)
* [Contributing](.github/CONTRIBUTING.md)
* [Release History](CHANGELOG.md)
* [License](#license)

<a name="overview"></a>
## Overview
The cmake-modules contains basic reusable building blocks for cmake C projects.<br>
Those include:

* Downloading git repository
* Downloading github repository
* Setting variables for sources, headers, etc... for downloaded repositories
* Add test targets easily
* Run ccpcheck
* Run uncrustify
* Create and increment build file
* Run xxd on resource files

<a name="usage"></a>

Include the cmake modules in the module path

```cmake
list(APPEND CMAKE_MODULE_PATH "cmake-modules/src")
```

Load the cmake module

```cmake
include(utils)
```

Another way is to automatically download it if missing, for example:

```cmake
if(NOT EXISTS "target/cmake-modules/src/utils.cmake")
  execute_process(COMMAND git clone https://github.com/sagiegurari/cmake-modules.git)
endif()
include("target/cmake-modules/src/utils.cmake")
```

Use the different capabilities in your CMakeLists.txt for example:

```cmake
utils_add_external_github_lib(
  REPO_USERNAME sagiegurari
  REPO_NAME c_scriptexec
  TAG_NAME "0.1.3"
  LIBRARY_NAME scriptexec
  LIBRARY_PARENT_DIRECTORY target
)

utils_setup_c_test(
  NAME
    stability
    long_run
    valid_input
    invalid_input
  ADDITIONAL_SOURCES "test/core.c;test/core.h"
  COMPILATION_FLAGS "-Werror -Wall -Wextra -Wcast-align -Wunused -Wshadow -Wpedantic"
  BINARY_DIRECTORY "target/bin"
)

utils_setup_c_all_tests(
  ADDITIONAL_SOURCES "test/core.c;test/core.h"
  COMPILATION_FLAGS "-Werror -Wall -Wextra -Wcast-align -Wunused -Wshadow -Wpedantic"
  BINARY_DIRECTORY "target/bin"
)
```

## Contributing
See [contributing guide](.github/CONTRIBUTING.md)

<a name="history"></a>
## Release History

See [Changelog](CHANGELOG.md)

<a name="license"></a>
## License
Developed by Sagie Gur-Ari and licensed under the Apache 2 open source license.
