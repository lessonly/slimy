# frozen_string_literal: true

module Slimy
  module Reporters
    # reporter that logs to rails logs
    # this will not send the data anywhere else
    class RailsLogReporter
      def initialize(level: :debug)
        @level = level
      end

      def report(context)
        log(context.debug_format)
      end

      def log(msg)
        ::Rails.logger.send(@level, msg)
      end
    end
  end
end
