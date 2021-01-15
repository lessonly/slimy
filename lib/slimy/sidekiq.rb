# frozen_string_literal: true

module Slimy
  # sidekiq integration for slimy
  module Sidekiq
    autoload :SLIMiddleware, "slimy/sidekiq/middleware"
  end
end
