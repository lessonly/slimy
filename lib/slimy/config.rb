module Slimy
  class Configuration

    def initialize
      @reporter = nil
    end

    attr_accessor :reporter


    def self.default
      @@default ||= Configuration.new
    end

    def configure
      yield(self) if block_given?
    end
  end
end