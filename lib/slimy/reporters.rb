# frozen_string_literal: true

require "slimy/reporters/reporter"

module Slimy
  # integrations for sending recorded data somewhere for long term storage
  module Reporters
    autoload :RailsLogReporter, "slimy/reporters/rails_log_reporter"
    autoload :DatadogReporter, "slimy/reporters/datadog"
  end
end
