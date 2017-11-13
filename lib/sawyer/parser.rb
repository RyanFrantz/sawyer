module Sawyer
  class Parser

    attr_reader :logfile, :offset_file
    def initialize(logfile = '', offset_file = '')
      @logfile = logfile
      @offset_file = offset_file
    end

    # Should return a hash of Regexp-to-string pairs.
    # The Regexp object should be a compiled regular expression that will
    # be used to match lines.
    # The string value should be the name of a metric that will be
    # passed to a metric publisher in the event a line is matched.
    def regexes
      {}
    end

    def parse
      raise NotImplementedError, "Implement '##{__method__}' in the '#{__FILE__}' file!"
    end
  end
end
