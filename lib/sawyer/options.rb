require 'optparse'
require 'sawyer/version'

module Sawyer
  module Options
    # List the known publishers and exit.
    def list_publishers
      publishers = Dir.glob(File.dirname(__FILE__) + '/publishers/*')
      publishers.sort.each do |publisher|
        puts File.basename(publisher).gsub(/\.rb$/, '')
      end
      exit
    end

    # Parse command line options. Returns a hash of options.
    def parse_options
      # Defaults.
      options = {
        config_file: '/etc/sawyer/sawyer.yml',
        parser_root: '/usr/local/sawyer/parsers',
        publisher:   'stdout'
      }

      oparser = OptionParser.new do |opts|
        #opts.banner = opts.banner + "..."

        opts.on('-c',
                '--config-file CONFIG_FILE',
                'The path to the configuration file.' \
                " (DEFAULT: #{options[:config_file]})"
               ) do |config_file|
                  options[:config_file] = config_file
        end

        opts.on('-h',
                '--help',
                'Prints this help message') {
                  puts opts
                  exit
        }

        opts.on('-L',
                '--list-publishers',
                'List all publishers and exit.') {
                  list_publishers
        }

        opts.on('-l',
                '--log-file LOGFILE',
                'The path to the log file that will be tailed and parsed.' \
                ' (REQUIRED)'
               ) do |logfile|
                  options[:logfile] = logfile
        end

        opts.on('-o',
                '--offset-file OFFSET_FILE',
                'An optional path to the offset file that will contain the' \
                ' inode and byte offset used by logtail2.'
               ) do |offset_file|
                  options[:offset_file] = offset_file
        end

        opts.on('-P',
                '--publisher PUBLISHER',
                'The name of the publisher that will emit metrics' \
                " (DEFAULT: #{options[:publisher]})" \
                ' See --list-publishers for a list of publishers.'
               ) do |publisher|
                  options[:publisher] = publisher
        end

        opts.on('-p',
                '--parser PARSER',
                'The name of a parser module that will be used to parse the' \
                ' log file. (REQUIRED)'
               ) do |parser|
                  options[:parser] = parser
        end

        opts.on('-R',
                '--parser-root PARSER_ROOT',
                'The directory where parsers may be found.' \
                " (DEFAULT: #{options[:parser_root]})"
               ) do |parser_root|
                  options[:parser_root] = parser_root
        end

        opts.on('-v',
                '--version',
                'Show version and exit') {
                  puts "sawyer v#{Sawyer::VERSION}"
                  exit
        }

      end

      begin
        oparser.parse!
      rescue OptionParser::InvalidOption => e
        puts "Warning: #{e.message}"
        if e.message =~ /--pattern/
          puts 'Ah, this is likely parsed from `rspec` options. We can safely ignore this.'
        end
        puts 'Ignoring the option.'
      end

      # Test for the presence of required options.
      %w(logfile parser).each do |opt|
        raise OptionParser::MissingArgument, "'#{opt}' is a required option!" if options[opt.to_sym].nil?
      end

      options
    end
  end
end
