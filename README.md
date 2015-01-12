# TemperatureParser

Parses Temperature readings, never gets tired.

## Events
The application listens for events of type `sensor::received`, selectively
handling payloads whose `data` values match `temperature::*`.

Once a Temperature is parsed, a `temperature::new` event with a serialized
Temperature struct is published.

## Temperature Struct
```elixir
%Temperature{
  celsius:    25,
  fahrenheit: 77,
  kelvin:     298.15
}
```

## Deploying
Just do it:
```
$ mix.deps.get
$ mix.release
$ rel/temperature/bin/temperature start
```
You can also attach to a console to see output:
```
$ rel/temperature/bin/temperature console
```
