module Sawyer
  class Publisher
    # Our metrics hash is keyed by a string, which in many cases is the
    # dotted-type name of a metric. There are cases, however, where we need
    # to send a value for a metric multiple times, but tagged differently.
    # In those cases, the key will be a pipe-delimited (|) string, allowing
    # us to build up the metrics hash with each variation. In that case, we
    # need to sanitize the name from the key so that it's emitted as expected.
    # If the name isn't pipe-delimited, this has no effect and simply passes
    # back the name.
    # Returns a string.
    def sanitized_name(name = '')
      name.split('|').first
    end

    def publish(_metrics)
      raise NotImplementedError, "Implement ##{__method__} in #{__FILE__}!"
    end
  end
end
