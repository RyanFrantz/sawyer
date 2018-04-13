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

    # Should return a hash of keyed by Regexp objects.
    # The Regexp object should be a compiled regular expression that will
    # be used to match lines.
    # The value, in the default case, is a string representing the name of the
    # metric (i.e. 'wu.tang.finances'). In such a case, sawyer will assume the
    # metric is a basic counter. If a line is matched, the counter will be
    # incremented.
    # An alternate option is the value is a hash that defines the metric type
    # and any related attributes (i.e. a counter with a sample_rate of 0.25;
    # a gauge). A config-driven set of parsers might look like the following:
    # parsers:
    #   example_parser:
    #     regexes:
    #       - 'foo\w+': 'foo.name'
    #       - 'bar\d+': 'bar.count'
    #   next_example_parser:
    #     regexes:
    #       - "\\squux": 'quux.of.the.issue'
    #   example_with_metric_type:
    #     regexes:
    #       - '^wu':
    #          name: 'bond.issue'
    #          type: 'c'
    #       - 'tang$':
    #          name: 'financial.instrument'
    #          type: 'gauge'
    #       - 'cream':
    #          name: 'rules.it.all'
    #          type: 'c'
    #          sample_rate: '0.5'
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
    # We initialize the metric value to 0. We're doing this because GUTS
    # metrics are displayed via Grafana and Grafana refuses to display
    # graphs for metrics that have never been created in OpenTSDB
    # (even with the 'null as zero' display option). So, though it may
    # be a bit wasteful, we'll go ahead and send a 0 if there are no matches.
    # If our parser wants to explictly define the metric, we do not strictly
    # assume the metric is a counter; we manage it according to how it's
    # defined.
    def parse
      # TODO: Handle exit status > 0
      lines = `#{LOGTAIL} -f #{logfile} -o #{offset_file}`.split("\n")
      lines.each do |line|
        regexes.each do |re, metric|
          if re.match(line)
            if metric.is_a?(Hash)
              # We have a metric with custom arguments. Use them.
              # Example: A user defines config-based parsers like so:
              # parsers:
              #   ...
              #   example_with_metric_type:
              #     regexes:
              #       - '^wu':
              #          name: 'bond.issue'
              #          type: 'c'
              #       - 'tang$':
              #          name: 'financial.instrument'
              #          type: 'gauge'
              #       - 'cream':
              #          name: 'rules.it.all'
              #          type: 'c'
              #          sample_rate: '0.5'
              name = metric['name']
              if metrics.key?(name)
                metrics[name]['value'] += 1
              else
                metrics[name] = {}
                metrics[name]['value'] = 1
                # Add the custom arguments.
                metric.each do |k, v|
                  # We've used the name in our hash already.
                  next if k == 'name' # rubocop:disable Metrics/BlockNesting
                  metrics[name][k] = v
                end
              end
            else
              metrics[metric] = 0 unless metrics.key?(metric)
              # Increment if we've found a match.
              metrics[metric] += 1 if re.match(line)
            end
          end
        end
      end
    end
  end
end
