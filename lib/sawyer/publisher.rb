module Sawyer
  class Publisher
    def publish(metrics)
      raise NotImplementedError, "Implement ##{__method__} in #{__FILE__}!"
    end
  end
end
