require 'sawyer/publisher'

module Sawyer
  class Parser

    LOGTAIL = '/usr/sbin/logtail2'
    attr_reader :logfile, :offset_file
    def initialize(logfile, offset_file)
      @logfile = logfile
      @offset_file = offset_file
    end

    # Should return a hash of Regexp-to-string pairs.
    # The Regexp object should be a compiled regular expression that will
    # be used to match lines.
    # The string value should be the name of a metric (typically dot-delimited)
    # that will be passed to a metric publisher in the event a line is matched.
    # Returns an empty hash here but should be overridden in the parser subclass
    # that inherits this class.
    def regexes
      {}
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
          if re.match(line)
            if metrics.key?(metric)
              metrics[metric] += 1
            else
              metrics[metric] = 1
            end
          end
        end
      end
    end

    def publish
      p = Sawyer::Publisher.new
      p.publish(metrics)
    end
  end
end
