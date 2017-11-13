module Sawyer
  class Parser
	  class OpscodeExpander < Sawyer::Parser
	    def initialize
        super
	      #@logfile = '/var/log/opscode/opscode-expander/current' # vestigial
	    end

      def regexes
	      re_indexed_node = Regexp.new('INFO: indexed node')
	      re_index_fail   = Regexp.new('ERROR: Failed to post to solr')
	      {
	        re_indexed_node => 'chef.server.opscode-expander.index.success',
	        re_index_fail   => 'chef.server.opscode-expander.index.fail'
	      }
      end

	  end
  end
end
