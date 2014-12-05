
[![Rubygems][rubygems-badge]][rubygems]
[![API Documentation][yard-badge]][docs]

# Rozi

Rozi is a Ruby gem for working with all Ozi Explorer file formats. Currently
the implemented functionality is:

- Creating and writing waypoints to files (.wpt)
- Reading waypoints from files
- Creating and writing tracks to files (.plt)
- Creating Name Search Text files (.nst)

## Files

Text based file formats read by Ozi Explorer should be encoded as ISO-8859-1 and
use CRLF line endings (`\r\n`). Rozi will handle this for you, as long as you
use the methods that accept file paths. Rozi internally uses the
[`Rozi.open_file`][Rozi.open_file] function, which creates and returns (or
yields) a `File` instance with the correct encoding settings for both reading
and writing Ozi Explorer file formats.

Example:

```ruby
Rozi.open_file("file_path.wpt", "w") { |file|
  file.write("Østre aker\n")   # Writes "Østre aker\r\n" in ISO-8859-1
}

Rozi.open_file("file_path.wpt", "r") { |file|
  file.read   # Reads "Østre aker\n" as UTF-8
}
```

## Datums

Rozi performs input validation on datums. If you try to set the datum property
of an object to a datum that isn't supported by Ozi Explorer, Rozi will raise an
exception. The constant [`Rozi::DATUMS`][Rozi::DATUMS] contains all datums that
Ozi Explorer supports.

## Colors

Any time you set colors in Rozi, you can either use the three-byte integer
representation that Ozi Explorer expects, or you can use a hex string like
"RRGGBB" and Rozi will convert it for you. Example:

```ruby
# Identical
Rozi::Waypoint.new(bg_color: "ABCDEF")
Rozi::Waypoint.new(bg_color: 0xEFCDAB)
Rozi::Waypoint.new(bg_color: 15715755)
```

## Creating waypoint files

Rozi defines a `WaypointFile` class, which mimics the standard library `File`
class. The waypoint file class has two important methods:

  - [`#write_properties`][Rozi::WaypointFile#write_properties]
  - [`#write_waypoint`][Rozi::WaypointFile#write_waypoint]

The waypoint file "properties" are the file-wide data contained in the top 4
lines of the file. In the case of waypoint files, that's just the waypoint file
version and the geodetic datum.

To write file properties, the file *must be empty*. Here's an example:

```ruby
properties = Rozi::WaypointFileProperties.new(version: "1.1", datum: "WGS 84")

wpt = Rozi::WaypointFile.open("/path/to/file.wpt", "w")
wpt.write_properties(properties)
```

The properties displayed here happens to be the defaults for Rozi, so you can
skip this step if they work for you. When writing the first waypoint, the
default properties will be added first.

Here's how you write waypoints:

```ruby
wpt = Rozi::WaypointFile.open("/path/to/file.wpt", "w")

wpt.write_waypoint Rozi::Waypoint.new(
  name: "Foo", latitude: 12.34, longitude: 56.78
)
wpt.write_waypoint Rozi::Waypoint.new(
  name: "Bar", latitude: 12.34, longitude: 56.78
)

wpt.close
```

Alternatively, you can use a block for `WaypointFile.open`, just like with
`File.open`:

```ruby
Rozi::WaypointFile.open("/path/to/file.wpt", "w") { |wpt|
  # ...
}
```

Rozi also provides the function `Rozi.write_waypoints` for opening a file,
writing properties, writing waypoints and closing the file in one step. Example:

```ruby
waypoints = [
  Rozi::Waypoint.new(name: "Foo", latitude: 12.34, longitude: 56.78),
  Rozi::Waypoint.new(name: "Bar", latitude: 12.34, longitude: 56.78)
]

Rozi.write_waypoints(waypoints, "/path/to/file.wpt", datum: "WGS 84")
```

WGS 84 is the default datum, so specifying it is unnecessary, but it illustrates
how waypoint file properties can be set using keyword arguments.

See:

  - [`Rozi.write_waypoints`][Rozi.write_waypoints]
  - [`Rozi::WaypointFileProperties`][Rozi::WaypointFileProperties]
  - [`Rozi::Waypoint`][Rozi::Waypoint]
  - [`Rozi::WaypointFile`][Rozi::WaypointFile]

## Reading waypoint files

Reading waypoints from waypoint files is even easier than writing them:

```ruby
wpt = Rozi::WaypointFile.open("/path/to/file.wpt", "r")

properties = wpt.read_properties

# The most basic reading method
first_waypoint = wpt.read_waypoint
second_waypoint = wpt.read_waypoint

# Iterating over all the waypoints in the file
wpt.each_waypoint { |waypoint|
  puts "#{waypoint.name} - #{waypoint.latitude},#{waypoint.longitude}"
}

# Reading all waypoints into an array
waypoints = wpt.each_waypoint.to_a
```

See:

  - [`Rozi::WaypointFile`][Rozi::WaypointFile]

## Creating track files

Creating track files is very similar to creating waypoint files. Instead of the
`WaypointFile` class, you use the `TrackFile` class. Instead of writing
`Waypoint` objects, you write `TrackPoint` objects. Instead of using
`WaypointFileProperties`, you use `TrackProperties`.

One thing to note about track files is that the file-wide properties contain a
lot more information. They contain the track color, track width, track
description and much more. See [`Rozi::TrackProperties`][Rozi::TrackProperties]
for more information.

Rozi also has a `Rozi.write_waypoints` equivalent for writing tracks:

```ruby
track_points = [
  Rozi::TrackPoint(latitude: 12.34, longitude: 56.78),
  Rozi::TrackPoint(latitude: 23.45, longitude: 67.89)
]

Rozi.write_track(track_points, "/path/to/file.plt", color: "FF0000")
```

See:

  - [`Rozi.write_track`][Rozi.write_track]
  - [`Rozi::TrackProperties`][Rozi::TrackProperties]
  - [`Rozi::TrackPoint`][Rozi::TrackPoint]
  - [`Rozi::TrackFile`][Rozi::TrackFile]

## Creating name search text files

See [Ozi Explorer: Name Search][name-search] for information about Name Search.
An NST file has to be converted into a Name Database using the ["Name Search
Creator"][name-search-creator] tool before they can be used by Ozi Explorer.

Rozi aims to be consistent and intuitive, so creating NST files is pretty much
the exact same process as creating waypoint files and track files:

```ruby
properties = Rozi::NameSearchProperties.new(
  datum: "WGS 84", comment: "Generated by Rozi!"
)

nst = Rozi::NameSearchTextFile.open("/path/to/file.nst", "w")

nst.write_properties(properties)
nst.write_name Rozi::Name.new(name: "Foo", latitude: 12.34, longitude: 56.78)
nst.write_name Rozi::Name.new(name: "Bar", latitude: 23.45, longitude: 67.89)

nst.close
```

Or using the module function:

```ruby
names = [
  Rozi::Name.new(name: "Foo", latitude: 12.34, longitude: 56.78),
  Rozi::Name.new(name: "Bar", latitude: 23.45, longitude: 67.89)
]

Rozi.write_nst(
  names, "/path/to/file.nst", datum: "WGS 84", comment: "Generated by Rozi!"
)
```

See:

  - [`Rozi.write_nst`][Rozi.write_nst]
  - [`Rozi::NameSearchProperties`][Rozi::NameSearchProperties]
  - [`Rozi::Name`][Rozi::Name]
  - [`Rozi::NameSearchFile`][Rozi::NameSearchFile]



[rubygems]: https://rubygems.org/gems/rozi
[docs]: http://www.rubydoc.info/gems/rozi
[rubygems-badge]: https://badge.fury.io/rb/rozi.svg
[yard-badge]: http://b.repl.ca/v1/yard-docs-blue.png

[name-search]: http://www.oziexplorer3.com/namesearch/wnamesrch.html
[name-search-creator]: http://www.oziexplorer3.com/namesearch/namesearch_setup.exe

[Rozi.open_file]: http://www.rubydoc.info/gems/rozi/Rozi#open_file-class_method

[Rozi::DATUMS]: http://www.rubydoc.info/gems/rozi/Rozi#DATUMS-constant

[Rozi::WaypointFile#write_properties]: http://www.rubydoc.info/gems/rozi/Rozi/WaypointFile#write_properties-instance_method
[Rozi::WaypointFile#write_waypoint]: http://www.rubydoc.info/gems/rozi/Rozi/WaypointFile#write_waypoint-instance_method
[Rozi.write_waypoints]: http://www.rubydoc.info/gems/rozi/Rozi#write_waypoints-class_method
[Rozi::WaypointFileProperties]: http://www.rubydoc.info/gems/rozi/Rozi/WaypointFileProperties
[Rozi::Waypoint]: http://www.rubydoc.info/gems/rozi/Rozi/Waypoint
[Rozi::WaypointFile]: http://www.rubydoc.info/gems/rozi/Rozi/WaypointFile

[Rozi.write_track]: http://www.rubydoc.info/gems/rozi/Rozi#write_track-class_method
[Rozi::TrackProperties]: http://www.rubydoc.info/gems/rozi/Rozi/TrackProperties
[Rozi::TrackPoint]: http://www.rubydoc.info/gems/rozi/Rozi/TrackPoint
[Rozi::TrackFile]: http://www.rubydoc.info/gems/rozi/Rozi/TrackFile

[Rozi.write_nst]: http://www.rubydoc.info/gems/rozi/Rozi#write_nst-class_method
[Rozi::NameSearchProperties]: http://www.rubydoc.info/gems/rozi/Rozi/NameSearchProperties
[Rozi::Name]: http://www.rubydoc.info/gems/rozi/Rozi/Name
[Rozi::NameSearchFile]: http://www.rubydoc.info/gems/rozi/Rozi/NameSearchFile
