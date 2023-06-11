# DWDataReader

[![CI](https://github.com/fleimgruber/DWDataReader.jl/workflows/CI/badge.svg)](https://github.com/fleimgruber/DWDataReader.jl/actions?query=workflow%3ACI)
[![codecov](https://codecov.io/gh/fleimgruber/DWDataReader.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/fleimgruber/DWDataReader.jl)
[![deps](https://juliahub.com/docs/DWDataReader/deps.svg)](https://juliahub.com/ui/Packages/DWDataReader/HHBkp?t=2)
[![version](https://juliahub.com/docs/DWDataReader/version.svg)](https://juliahub.com/ui/Packages/DWDataReader/HHBkp)
[![pkgeval](https://juliahub.com/docs/DWDataReader/pkgeval.svg)](https://juliahub.com/ui/Packages/DWDataReader/HHBkp)

*Reader for DEWESoft data files*

## Installation

The package is registered in the [`General`](https://github.com/JuliaRegistries/General) registry and so can be installed at the REPL with `] add DWDataReader`.

## Example usage

```julia
using Printf, Statistics, DWDataReader

dewefile = "test/testfiles/Example_Drive01.d7d"
f = DWDataReader.File(dewefile)
println(f.info)
println(f)
for ch in f.channels
    @printf "chan: %s, mean: %.3f" ch.name mean(DWDataReader.scaled(ch)[:, 2])
end
```

## Supported Systems

### Windows

Only MSYS2 MinGW toolchain is supported. Please provide PRs for other toolchains (e.g. MSVC).

Run this command to install the toolchain (on MSYS2 MINGW64 shell):

```bash
pacman -S --needed base-devel mingw-w64-x86_64-toolchain
```

Make sure these MSYS2 paths are in the $PATH environment variable for the julia process using DWDataReader.jl:

* `C:\Users\user\opt\msys64\usr\bin`
* `C:\Users\user\opt\msys64\mingw64\bin`

### Linux

GCC toolchain is supported.

## Documentation

- [**STABLE**][docs-stable-url] &mdash; **most recently tagged version of the documentation.**
- [**LATEST**][docs-latest-url] &mdash; *in-development version of the documentation.*

## Project Status

The package is tested against Julia `1.8.5` on Linux and Windows.

## Contributing and Questions

Contributions are very welcome, as are feature requests and suggestions. Please open an
[issue][issues-url] if you encounter any problems or would just like to ask a question.

[docs-latest-img]: https://img.shields.io/badge/docs-latest-blue.svg
[docs-latest-url]: https://fleimgruber.github.io/DWDataReader.jl/latest

[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-stable-url]: https://fleimgruber.github.io/DWDataReader.jl/stable

[ci-img]: https://github.com/fleimgruber/DWDataReader.jl/workflows/CI/badge.svg
[ci-url]: https://github.com/fleimgruber/DWDataReader.jl/actions?query=workflow%3ACI+branch%3Amaster

[codecov-img]: https://codecov.io/gh/fleimgruber/DWDataReader.jl/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/fleimgruber/DWDataReader.jl

[issues-url]: https://github.com/fleimgruber/DWDataReader.jl/issues
