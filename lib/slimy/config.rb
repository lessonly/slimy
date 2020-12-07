# frozen_string_literal: true

module Slimy
  # Class for configration of Slimy tooling
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
