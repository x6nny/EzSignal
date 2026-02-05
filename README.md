# EzSignal

**EzSignal** is a lightweight, type-safe Signal implementation for Roblox development. It features a functional API design, a built-in global registry for storing signals, and a unique "Link" system that allows you to group and fire multiple signals simultaneously.

## Features

* **Type-Safe:** Fully typed with Luau.
* **Asynchronous:** Connections are fired using `task.spawn`, ensuring errors in one listener do not yield the thread or stop other listeners.
* **Global Registry:** Store and retrieve signals globally by name without passing object references.
* **Signal Linking:** Group multiple signals into a "Link" and fire them all with a single call.
* **Functional Design:** Uses a wrapper-based approach (e.g., `EzSignal.Connect(sig, fn)`) rather than metatables, which ensures speed, as sending the signal class through the function is faster than using self.

## Installation

1. Create a `ModuleScript` in Roblox Studio.
2. Name it `EzSignal`.
3. Paste the source code into the script.
4. Place the module in `ReplicatedStorage` (or your preferred shared location).

## Usage Examples

### Basic Usage

```lua
local EzSignal = require(game.ReplicatedStorage.EzSignal)

-- 1. Create a signal
local mySignal = EzSignal.new()

-- 2. Connect a listener
local disconnectFn = EzSignal.Connect(mySignal, function(message, count)
    print("Received:", message, count)
end)

-- 3. Fire the signal
EzSignal.Fire(mySignal, "Hello World", 100)

-- 4. Disconnect later
disconnectFn()

```

### Using the Signal Registry (Storage)

The registry allows you to access signals from different scripts without requiring the original signal object.

```lua
-- Script A
local signal = EzSignal.new()
EzSignal.store("LevelUp", signal)

-- Script B (somewhere else)
local levelUpSig = EzSignal.get("LevelUp")
if levelUpSig then
    EzSignal.Connect(levelUpSig, function()
        print("Level Up Triggered!")
    end)
end

```

### Signal Linking

Links allow you to group signals together. When you fire a Link, every enabled signal inside that link fires.

```lua
local link = EzSignal.newLink()
local signalA = EzSignal.new()
local signalB = EzSignal.new()

-- Add signals to the link
EzSignal.addLink(link, signalA)
EzSignal.addLink(link, signalB)

-- Connecting to individual signals
EzSignal.Connect(signalA, function() print("A Fired") end)
EzSignal.Connect(signalB, function() print("B Fired") end)

-- Fire the LINK (fires both A and B)
EzSignal.Fire(link) 

```

---

## API Reference

### Constructors

#### `EzSignal.new() -> signal`

Creates a new signal object.

#### `EzSignal.newLink() -> link`

Creates a new Link object used to group multiple signals.

### Connections & Firing

#### `EzSignal.Connect(signal, callback) -> () -> ()`

Connects a function to a signal.

* **Returns:** A function that, when called, disconnects the listener.

#### `EzSignal.Fire(signal | link, ...args)`

Fires a specific signal OR a Link.

* If a **Signal** is passed: Fires all connections for that signal.
* If a **Link** is passed: Iterates through all signals in the link and fires them.
* *Note: This uses `task.spawn` internally.*

#### `EzSignal.fireList(list, ...args)`

Iterates through a table of signals and fires all of them with the provided arguments.

#### `EzSignal.DisconnectAll(signal)`

Removes all connections from the given signal.

### State Management

#### `EzSignal.Enable(signal, enabled)`

Toggles the signal on or off.

* If `false`, `EzSignal.Fire` will ignore this signal (even if fired via a Link).

### Global Storage

#### `EzSignal.store(name, signal, override?)`

Stores a signal in the internal registry.

* `override` (bool, optional): If true, overwrites any existing signal with this name.

#### `EzSignal.get(name) -> signal?`

Retrieves a signal from the registry by name. Returns `nil` if not found.

#### `EzSignal.remove(name)`

Removes a signal from the registry.

#### `EzSignal.list() -> StoredSignals`

Returns the raw table of all stored signals.

### Link Management

#### `EzSignal.addLink(link, signal) -> () -> ()`

Adds a signal to a Link group.

* **Returns:** A cleanup function that removes the signal from the link when called.

#### `EzSignal.clearLink(link)`

Removes all signals from the specified Link.

---

## Types

For Luau type checking:

```lua
type signal = { 
    Connections : { (...any) -> () },
    Enabled : boolean,
    link : string?
}

type link = {
    isLink : boolean,
    signals : { signal }
}

```

## License

[MIT](https://choosealicense.com/licenses/mit/)
