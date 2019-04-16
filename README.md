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
var foreigner = preload('res://contrib/foreigner/foreigner.gdns').new()
var library = foreigner.open('libsteam_api.so')

library.define('SteamAPI_Init', 'void', [])
prints(library.invoke('SteamAPI_Init'))

library.define('SteamAPI_IsSteamRunning', 'uchar', [])
prints(library.invoke('SteamAPI_IsSteamRunning'))  # Prints 1
prints(library.invoke('SteamAPI_IsSteamRunning'))  # Prints 1
prints(library.invoke('SteamAPI_IsSteamRunning'))  # Prints 1
```

