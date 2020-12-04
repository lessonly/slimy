require "slimy/version"
require "slimy/context"
require "slimy/config"
require "slimy/rack"
require "slimy/rails"
require "slimy/reporters"


module Slimy
  class << self
    def configure
      if block_given?
        yield(Configuration.default)
      else
        Configuration.default
      end
    end
  end
end