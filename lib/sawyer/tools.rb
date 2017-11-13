module Sawyer
  module Tools
    # Accept a snaked-cased string and camel-case it, capitalizing each word.
    # This will be used to identify the name of the parser classes, based on
    # the name of a given parser file.
    def camelize(s = '')
      s.split('_').collect(&:capitalize).join
    end
  end
end
