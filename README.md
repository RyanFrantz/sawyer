# sawyer

A tool for parsing logs and emitting metrics.

`sawyer` is inspired by Etsy's [`logster`](https://github.com/etsy/logster). [1]
When called, `sawyer` needs to know which log file to tail and which parser to
use. It will tail the log file, parse each line to determine if it matches
one or more regular expressions defined in the parser, and increment a
counter for an appropriate metric (also defined in the parser). Any metrics
that are generated will be output based on the requested publisher.

`sawyer` will write a file that stores the log file's inode number and the
byte offset it saw during it's most recent execution. This offset file will
be referenced on future runs to ensure `sawyer` only parses recent log
activity.

## A Note About Offset Files

It is normal, and expected, to see the first run of `sawyer` produce large
metric values for matching log lines. This is often due to the fact that a log
has many hours' (or days') worth of activity that needs to be parsed before
`sawyer` can capture the most recent offset value.

`sawyer` should also be smart enough to know that a log file has been rotated.
It does this by tracking the log file's inode and verifying that the target log
file's inode matches the reference it has stored in the offset file. If there is
a mismatch, `sawyer` will begin parsing the updated/rotated log file from the start
(i.e. offset `0`).

## Installing `sawyer`

Install `sawyer` via `gem`:

`gem install sawyer-log-parser`

This gem is stored in Bloomberg's internal (Artifactory-hosted) Rubygems repo.

## Using `sawyer`

See the following usage output:

```sh
Usage: sawyer [options]
    -c, --config-file CONFIG_FILE    The path to the configuration file. (DEFAULT: /etc/sawyer/sawyer.yml)
    -h, --help                       Prints this help message
    -L, --list-publishers            List all publishers and exit.
    -l, --log-file LOGFILE           The path to the log file that will be tailed and parsed. (REQUIRED)
    -o, --offset-file OFFSET_FILE    An optional path to the offset file that will contain the inode and byte offset used by logtail2.
    -P, --publisher PUBLISHER        The name of the publisher that will emit metrics (DEFAULT: stdout) See --list-publishers for a list of publishers.
    -p, --parser PARSER              The name of a parser module that will be used to parse the log file. (REQUIRED)
    -R, --parser-root PARSER_ROOT    The directory where parsers may be found. (DEFAULT: /usr/local/sawyer/parsers)
    -v, --version                    Show version and exit
```

**NOTE**: `--log-file` and `--parser` are required.

An example command would look like the following
(line breaks added for legibility):

```
sawyer --log-file /var/log/opscode/opscode-solr/current \
  --parser opscode_solr \
  --publisher aggrocrag
```

## Parsers

Parsers are expected to reside in `/usr/local/sawyer/parsers` but can be
found in any directory (specify `--parser-root` to override the default).

See [sawyer_parsers](https://bbgithub.dev.bloomberg.com/SystemsCoreEngineering/sawyer_parsers)
for available parsers.

### Configuration-derived Parsers

For convenience, `sawyer` supports parsers defined in a YAML configuration file
(defaults to `/etc/sawyer/sawyer.yml`). Parsers are defined under the `parsers`
key, given a unique name (passed to `sawyer` via the `-p` option), and include
one or more regex-to-metric name items under the 'regexes' list. See below for
an example:

```yaml
parsers:
  example_parser:
    regexes:
      - 'foo\w+': 'foo.name'
      - 'bar\d+': 'bar.count'
  next_example_parser:
    regexes:
      - "\\squux": 'quux.of.the.issue'
```

## Publishers

Publishers are used to emit metrics in some way (i.e. to standard output, `aggrocrag`, etc.).
`sawyer` provides the `aggrocrag` and `stdout` publishers.

To determine which publishers are available to `sawyer`, run `sawyer --list-publishers`:

```sh
$ sawyer --list-publishers
aggrocrag
stdout
```

# Footnotes

[1] `sawyer` depends on the `logtail2` script available in the `logcheck` package.
