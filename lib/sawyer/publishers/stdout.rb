module Sawyer
  class Publisher
    class Stdout < Sawyer::Publisher
      def publish(metrics)
        puts metrics
      end
    end
  end
end
