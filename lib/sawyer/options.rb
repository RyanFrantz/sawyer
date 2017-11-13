require 'choice'
require 'sawyer/version'

module Sawyer
  module Options
		# Parse command line options and return the choices hash.
    def parse_options
      Choice.options do
        header ''
        header 'Options:'

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

        option :parser, :required => true do
          short '-p'
          long  '--parser=PARSER'
          desc  'The name of a parser module that will be used to parse the log file. (REQUIRED)'
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
