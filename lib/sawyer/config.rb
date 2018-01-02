require 'yaml'

module Sawyer
  module Config
    # Parse the config, if it exists.
    def parse_config(config_file = '')
        parsed_config = {} # Initialize.
        if File.exist?(config_file)
          begin
            y = YAML.load_file(config_file)
          rescue Psych::SyntaxError => e
            error "[#{e.class}] Failed to parse '#{config_file}'!!"
            error e.message
            exit 1
          end
          # Merge the contents of the config into @config.
          parsed_config.merge!(y)
        end
        parsed_config
    end
  end
end
