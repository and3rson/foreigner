# Foreigner: a foreign function interface library for Godot 3.1 (WIP)

This repo contains a WIP variant of a FFI adapter for Godot.

# Compiling & testing

```bash
# Build foreigner.so to use with Godot
make GODOTCPP_PATH=path/to/godot/cpp/sources GODOT_PATH=path/to/godot/sources
# Build testlib.so with some exposed methods
# and run Godot script that loads and tests testlib.so via foreigner API.
make test GODOTCPP_PATH=path/to/godot/cpp/sources GODOT_PATH=path/to/godot/sources
```

# Usage

First of all, download & build godot-cpp according to their instructions.

Then edit the `foreigner.gdns` file to match the path of your built `foreigner.so`.

Lastly, use it in Godot as follows:

```gdscript
# Generic example
# See ffi.h of libffi for a list of
# possible argument types.
# One extra type is available - "string".
# It allows passing & returning string `Variant`s
# as char* and const char*.

var foreigner = preload('res://contrib/foreigner/foreigner.gdns').new()
var library = foreigner.open('./testlib.so')

library.define('getNumber', 'sint32', [])
print(library.invoke('getNumber'))  # prints 42

library.define('add2i', 'sint32', ['sint32', 'sint32'])
print(library.invoke('add2i', [6, 8]))  # Prints 14

library.define('add3d', 'double', ['double', 'double', 'double'])
print(library.invoke('add3d', [3.0, 4.0, 5.0]))  # Prints 12


# Pointers
# Assuming we have the following shared library functions:
# uint32_t* allocateInt(uint32_t value) { return new int32_t(value) }
# uint32_t retrieveInt(uint32_t *value) { return *value; }

library.define('allocateInt', 'pointer', ['sint32'])
library.define('retrieveInt', 'sint32', ['pointer'])
result = library.invoke('retrieveInt', [library.invoke('allocateInt', [1337])])
print(result)  # Prints 1337


# Strings
library.define('getMessage', 'string', [])
print(library.invoke('getMessage', []))  # Prints Hello world!

library.define('joinStrings', 'string', ['string', 'string'])
print(library.invoke('joinStrings', ['Foo', 'bar']))  # Prints Foobar


# Steam example

var foreigner = preload('res://contrib/foreigner/foreigner.gdns').new()
var library = foreigner.open('./libsteam_api.so')

library.define('SteamAPI_Init', 'void', [])
prints(library.invoke('SteamAPI_Init'))

library.define('SteamAPI_IsSteamRunning', 'uchar', [])
prints(library.invoke('SteamAPI_IsSteamRunning'))  # Prints 1

```

# Known limitations

- Only basic types are currently supported: int, float, strings and pointers.
- Only Linux is supported right now. This is easy to improve.
- Memory leaks are possible. This needs some minor attention.
- Pointer sizes should be added for 8-, 16-, 32-, & 64-bit pointers. Currently uint64_t* is used.
