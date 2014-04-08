# Monkey patch in require relative for versions of ruby that do not support it
unless Kernel.respond_to?(:require_relative)
  module Kernel
    def require_relative(path)
      require File.join(File.dirname(caller[0]), path.to_str)
    end
  end
end

require_relative "codekit/version"

module Att
  # @author kh455g
  module Codekit
    module Auth
      require_relative "codekit/auth" 
    end

    module Service
      require_relative "codekit/service"
    end

  end
end
