require 'sawyer/config'
require 'sawyer/options'
require 'sawyer/parser'
require 'sawyer/tools'

module Sawyer
  class Runner
    include Sawyer::Config
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

    def config
      @config ||= parse_config(options[:config_file])
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

    def parser_name
      options[:parser].gsub(/\.rb$/, '')
    end

    def parser_path
      @parser_path ||= "#{parser_root}/#{parser_name}.rb"
    end

    # Test if the parser is defined in the config.
    # Returns true or false.
    def parser_defined_in_config
      config['parsers'] and config['parsers'].keys.include?(parser_name)
    end

    # Generates a hash of regex-to-metric name that will be assigned to a
    # config-derived parser object via its #regexes= method.
    def add_regexes_from_config
      regexes = {}
      if config['parsers'][parser_name].key?('regexes')
        config['parsers'][parser_name]['regexes'].each do |rehash|
          rehash.each do |pattern, metric|
            re = Regexp.new(pattern)
            regexes[re] = metric
          end
        end
      end
      regexes
    end

    # Returns an anonymous Class object we can use to subclass parsers defined
    # in the config.
    def parser_parent_class
      Class.new(Sawyer::Parser)
    end

    # Returns the parser's class as as string.
    def parser_class
      parent = parser_parent_class.superclass.to_s
      # Sawyer::Parser::Wutang
      @parser_class ||= "#{parent}::#{camelize(parser_name)}"
    end

    # We require parsers external to ourselves as we expect them to be provided
    # by the operator.
    # Custom parsers (i.e. actual code) take precedence, followed by parsers
    # defined in the config.
    def load_parser
      if File.exist?(parser_path)
        require parser_path
      elsif parser_defined_in_config
        # Create a subclass of Sawyer::Parser. Magic^WMeta-programming!
        Sawyer::Parser.const_set(camelize(parser_name).to_sym, parser_parent_class)
      end
      klass = Object.const_get(parser_class)
      parser = klass.new(logfile, offset_file)
      parser.from_config = true if parser_defined_in_config
      # TODO: Add regexes for config-derived parser.
      parser.regexes = add_regexes_from_config if parser_defined_in_config
      parser
    end

    # Instantiate and return a parser object.
    def parser
      #load_parser
      #klass = Object.const_get(parser_class)
      #@parser ||= klass.new(logfile, offset_file)
      @parser ||= load_parser
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
      unless (File.exist?(parser_path) or parser_defined_in_config)
        error = "Unable to locate parser '#{parser_name}' either as a class " \
          "at '#{parser_path}' or as a definition in the config " \
          "('#{options[:config_file]}')!"
        puts error
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
