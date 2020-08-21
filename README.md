# cmake-modules

[![Release](https://img.shields.io/github/v/release/sagiegurari/cmake-modules)](https://github.com/sagiegurari/cmake-modules/releases)
[![license](https://img.shields.io/github/license/sagiegurari/cmake-modules)](https://github.com/sagiegurari/cmake-modules/blob/master/LICENSE)

> Reusable cmake utilties for C projects.

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

<a name="usage"></a>

Include the cmake modules in the module path

```cmake
list(APPEND CMAKE_MODULE_PATH "./cmake-modules/src")
```

Load the cmake module

```cmake
include(utils.cmake)
```

Use the different capabilities in your CMakeLists.txt for exmaple:

```cmake
utils_add_external_github_lib(sagiegurari c_string_buffer "v0.1.2" string_buffer target)
```

## Contributing
See [contributing guide](.github/CONTRIBUTING.md)

<a name="history"></a>
## Release History

See [Changelog](CHANGELOG.md)

<a name="license"></a>
## License
Developed by Sagie Gur-Ari and licensed under the Apache 2 open source license.
