# frozen_string_literal: true

require "slimy/reporters/reporter"

module Slimy::Reporters
  autoload :RailsLogReporter, "slimy/reporters/rails_log_reporter"
  autoload :DatadogReporter, "slimy/reporters/datadog"
end
