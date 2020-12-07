# frozen_string_literal: true

module Slimy::Reporters
  class RailsLogReporter
    def initialize(level: :debug)
      @level = level
    end

    def report(context)
      log(context.debug_format)
    end

    def log(msg)
      Rails.logger.send(@level, msg)
    end
  end
end
