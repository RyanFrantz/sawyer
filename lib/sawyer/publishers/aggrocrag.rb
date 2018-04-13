require 'socket'

module Sawyer
  class Publisher
    class Aggrocrag < Sawyer::Publisher
      # Send metrics to aggrocrag.
      # This is a very limited implementation of a library similar to that found
      # at https://bbgithub.dev.bloomberg.com/IPMonitoring/python-gutsapi
      # and https://bbgithub.dev.bloomberg.com/cchandle/ruby-gutsapi.
      def send_metric(name: '', value: '', type: 'c', sample_rate: '1.0', tags: {})
        require 'socket'
        msg = ['bb']
        msg << "#{name}:#{value}"
        msg << type
        msg << "@#{sample_rate}" if type == 'c'
        tag_msg = []
        tags.each_pair do |k, v|
          tag_msg << "#{k}:#{v}"
        end
        msg << "##{tag_msg.join(',')}" unless tag_msg.empty?
        full_msg = msg.join('|') + "\n"
        aggrocrag_host = 'localhost'
        aggrocrag_port = 8125
        u = UDPSocket.new
        u.send(full_msg, 0, aggrocrag_host, aggrocrag_port)
      end

      def publish(metrics)
        metrics.each do |name, value|
          if value.is_a?(Hash)
            # The metric has custom arguments. Use them.
            args = { name: name }
            value.each do |k, v|
              # TODO: Validate options and their values for correctness.
              args[k] = v
            end
            send_metric(args)
          else
            # Assume a simple counter type metric and let the defaults ride.
            send_metric(name: name, value: value)
          end
        end
      end
    end
  end
end
