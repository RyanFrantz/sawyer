require 'sawyer/options'
require 'sawyer/tools'

SAWYER_ROOT = '/var/log/sawyer'
LOGTAIL = '/usr/sbin/logtail2'
logfile = '/var/log/opscode/opscode-expander/current'
offset_file = logfile.gsub('/', '_').gsub(/^_/, '')
offset_path = "#{SAWYER_ROOT}/#{offset_file}.offset"

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
      @parser_root ||= '/usr/local/sawyer/parsers'
    end

    def parser_file
      options[:parser]
    end

    def parser_path
      @parser_path ||= "#{parser_root}/#{parser_file}.rb"
    end

    def parser_class
      parser_name = parser_file.gsub(/\.rb$/, '')
      @parser_class ||= camelize(parser_name)
    end

    def load_parser
      require parser_path
    end

    # Instantiate and return a parser object.
    def parser
      load_parser
      klass = Object.const_get(parser_class)
      klass.new(logfile = logfile, offset_file = offset_file)
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
    end
  end
end


#re_indexed_node = Regexp.new('INFO: indexed node')
#re_index_fail   = Regexp.new('ERROR: Failed to post to solr')
#
#regexes = {
#  re_indexed_node => 'chef.server.opscode-expander.index.success',
#  re_index_fail   => 'chef.server.opscode-expander.index.fail'
#}
#
#metrics = {}
#lines = `#{LOGTAIL} -f #{logfile} -o #{offset_path}`.split("\n")
#lines.each do |line|
#  regexes.each do |re, metric|
#    if re.match(line)
#      if metrics.key?(metric)
#        metrics[metric] += 1
#      else
#        metrics[metric] = 1
#      end
#    end
#  end
#end
#
#metrics.each do |metric, value|
#  puts "#{metric} = #{value}"
#end
