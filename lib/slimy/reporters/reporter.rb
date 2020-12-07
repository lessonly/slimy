# frozen_string_literal: true

module Slimy::Reporters
  class BaseReporter
    def report(_context)
      raise NotImplementedError
    end
  end
end
