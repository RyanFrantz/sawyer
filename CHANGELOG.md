# Changelog

## [0.0.7] - 2018-04-16
- Extends publisher class to include `#sanitized_name` method so we can support
pipe-delimited strings used as keys in the `metrics` hash.
- Keys are typically dotted-type metric names but because we support defining
tags for metrics, we might end up with two metrics (same name, different tags)
colliding with such a limited name space. In these cases, we build up a unique
string for the key that contains the metric name and additional information such
as type and defined tags, all delimited by pipe.

## [0.0.6] - 2018-04-13
- Adds support for defining metric type in a parser.

## [0.0.5] - 2018-01-08
- Gives operators the ability to define parsers via YAML config.

## [0.0.4] - 2017-11-16
- Initializes metric values to 0 by default.

## [0.0.3] - 2017-11-15
- Updates gemspec to support at least Ruby 2.0.

## [0.0.2] - 2017-11-14
- Updated the gem name to `sawyer-log-parser`.
 - https://github.com/lostisland/sawyer is a thing...

## [0.0.1] - 2017-11-14
- Initial release.
