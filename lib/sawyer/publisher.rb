module Sawyer
  class Publisher
    def publish
      raise NotImplementedError, "Implement #{__method__} in #{self}!"
    end
  end
end
