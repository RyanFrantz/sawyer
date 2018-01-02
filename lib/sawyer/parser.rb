require 'sawyer/publisher'

module Sawyer
  class Parser
    LOGTAIL = '/usr/sbin/logtail2'.freeze
    attr_reader :logfile, :offset_file
    attr_accessor :from_config
    def initialize(logfile, offset_file)
      @logfile = logfile
      @offset_file = offset_file
      # @from_config tells us if we're an auto-generated object based on a
      # parser defined in the config. Custom classes should NOT set this to true.
      @from_config = false
    end

    # Should return a hash of Regexp-to-string pairs.
    # The Regexp object should be a compiled regular expression that will
    # be used to match lines.
    # The string value should be the name of a metric (typically dot-delimited)
    # that will be passed to a metric publisher in the event a line is matched.
    # Returns an empty hash here but should be overridden in the parser subclass
    # that inherits this class.
    def regexes
      @regexes ||= {}
    end

    # Sets the 'regexes' hash.
    def regexes=(regex_hash)
      @regexes = regex_hash
    end

    # Should return a hash of metric-name-to-value pairs
    # The metric name should be one of the metrics defined in the 'regexes' hash.
    # The value should be an integer.
    # Returns an empty hash here but should be overridden in the parser subclass
    # that inherits this class.
    def metrics
      @metrics ||= {}
    end

    # Run logtail2, ingest the output, and parse the lines looking for matches.
    # If any are found, increment the appropriate metric counter.
    # This method may be overridden in the subclass that inherits this class.
    def parse
      # TODO: Handle exit status > 0
      lines = `#{LOGTAIL} -f #{logfile} -o #{offset_file}`.split("\n")
      lines.each do |line|
        regexes.each do |re, metric|
          # Initialize the metric to 0. We're doing this because GUTS
          # metrics are displayed via Grafana and Grafana refuses to display
          # graphs for metrics that have never been created in OpenTSDB
          # (even with the 'null as zero' display option). So, though it may
          # be a bit wasteful, we'll go ahead and send a 0 if there are no matches.
          metrics[metric] = 0 unless metrics.key?(metric)
          # Increment if we've found a match.
          metrics[metric] += 1 if re.match(line)
        end
      end
    end
  end
end
