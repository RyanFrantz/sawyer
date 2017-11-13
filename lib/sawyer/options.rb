require 'choice'
require 'sawyer/version'

module Sawyer
  module Options
		# Parse command line options and return the choices hash.
    def parse_options
      defaults = {
        parser_root: '/usr/local/sawyer/parsers',
        publisher:   'stdout'
      }
      Choice.options do
        header ''
        header 'Options:'

        option :list_publishers do
          long  '--list-publishers'
          desc  'List all publishers and exit.'
          action do
            publishers =  Dir.glob(File.dirname(__FILE__) + '/publishers/*')
            publishers.sort.each do |publisher|
              puts File.basename(publisher).gsub(/\.rb$/, '')
            end
            exit
          end
        end

        option :logfile, :required => true do
          short '-l'
          long  '--log-file=LOGFILE'
          desc  'The path to the log file that will be tailed and parsed. (REQUIRED)'
        end

        option :offset_file do
          short '-o'
          long  '--offset-file=OFFSET_FILE'
          desc  'An optional path to the offset file that will contain the inode and byte offset used by logtail2.'
        end

        option :parser_root do
          short   '-P'
          long    '--parser-root=PARSER_ROOT'
          desc    "The directory where parsers may be found. (DEFAULT: #{defaults[:parser_root]})"
          default defaults[:parser_root]
        end

        option :parser, :required => true do
          short '-p'
          long  '--parser=PARSER'
          desc  'The name of a parser module that will be used to parse the log file. (REQUIRED)'
        end

        option :publisher do
          long    '--publisher=PUBLISHER'
          desc    "The name of the publisher that will emit metrics (DEFAULT: #{defaults[:publisher]})"
          desc    'See --list-publishers for a list of publishers.'
          default defaults[:publisher]
        end

        option :version do
          short '-v'
          long  '--version'
          desc  'Show version and exit'
          action do
            puts "sawyer v#{Sawyer::VERSION}"
            exit
          end
        end

        footer ''
      end
      Choice.choices
    end
  end
end
