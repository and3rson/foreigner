# Foreigner: a foreign function interface library for Godot 3.1 (WIP)

This repo contains a WIP variant of a FFI adapter for Godot.

# Compiling

```bash
make GODOTCPP_PATH=path/to/godot/cpp/sources GODOT_PATH=path/to/godot/sources
```

# Usage

First of all, download & build godot-cpp according to their instructions.

Then edit the `foreigner.gdns` file to match the path of your built `foreigner.so`.

Lastly, use it in Godot as follows:

```gdscript
var foreigner = preload('res://foreigner.gdns').new()
prints('Foreigner:', foreigner)
var library = foreigner.open('libsteam_api.so')
prints('Library:', library)
# These are currently only few primitive functions that return specific data type. No real FFI yet!
prints(library.invoke('SteamAPI_Init'))  # Prints 1
prints(library.invoke_str('SteamAPI_GetSteamInstallPath'))  # Prints .
prints(library.invoke_bool('SteamAPI_IsSteamRunning'))  # Prints True
```

