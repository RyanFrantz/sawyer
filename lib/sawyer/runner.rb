require 'sawyer/options'
require 'sawyer/parser'
require 'sawyer/tools'

module Sawyer
  class Runner
    include Sawyer::Options
    include Sawyer::Tools

    def initialize
      @options = options
      @offset_root = offset_root
      @offset_path = offset_path
      @parser_root = parser_root
      @parser_path = parser_path
      @parser_class = parser_class
    end

    def options
      @options ||= parse_options
    end

    def logfile
      options[:logfile]
    end

    def offset_root
      @offset_root ||= '/var/log/sawyer'
    end

    # Returns the offset file defined on the command line or a computed path.
    def offset_file
      # Replace path separator with underscores. Strip the leading underscore.
      computed_offset_file = "#{logfile.gsub('/', '_').gsub(/^_/, '')}.offset"
      options[:offset_file] || "#{offset_root}/#{computed_offset_file}"
    end

    def offset_path
      @offset_path ||= offset_file
    end

    def parser_root
      @parser_root ||= options[:parser_root]
    end

    def parser_file
      options[:parser]
    end

    def parser_path
      @parser_path ||= "#{parser_root}/#{parser_file}.rb"
    end

    def parser_class
      parser_name = parser_file.gsub(/\.rb$/, '')
      @parser_class ||= "Sawyer::Parser::#{camelize(parser_name)}"
    end

    # We require parsers external to ourselves as we expect them to be provided
    # by the operator.
    def load_parser
      require parser_path
    end

    # Instantiate and return a parser object.
    def parser
      load_parser
      klass = Object.const_get(parser_class)
      @parser ||= klass.new(logfile, offset_file)
    end

    def publisher_name
      @publisher_name ||= options[:publisher]
    end

    # We require publishers relative to ourselves as we ship with them.
    def publisher_path
      @publisher_path ||= "#{File.dirname(__FILE__)}/publishers/#{publisher_name}.rb"
    end

    def load_publisher
      require_relative publisher_path
    end

    def publisher_class
      @publisher_class ||= "Sawyer::Publisher::#{camelize(publisher_name)}"
    end

    def publisher
      load_publisher
      klass = Object.const_get(publisher_class)
      @publisher ||= klass.new
    end

    def validate_logfile!
      unless File.exist?(logfile)
        puts "Unable to locate log file '#{logfile}'!"
        exit 1
      end
    end

    def validate_parser!
      unless File.exist?(parser_path)
        puts "Unable to locate parser '#{parser_path}'!"
        exit 1
      end
    end

    def run
      validate_logfile!
      validate_parser!
      parser.parse
      publisher.publish(parser.metrics)
    end
  end
end
