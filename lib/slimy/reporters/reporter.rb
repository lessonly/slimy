# frozen_string_literal: true

module Slimy
  # module for housing integrations that send data somewhere
  # for storage/analysis
  module Reporters
    # This is mostly a template for actualy implementations
    class BaseReporter
      def report(_context)
        raise NotImplementedError
      end
    end
  end
end
