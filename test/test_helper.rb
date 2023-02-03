# frozen_string_literal: true

require "minitest/autorun"
require 'spy/integration'
require "slimy"
require "timecop"

def freeze_ms(duration_ms)
  Timecop.freeze(Time.now + (duration_ms / 1000.0)) do
    yield
  end
end

def create_class(parent_klass)
  Class.new(parent_klass) do
  end
end

class DummyReporter
  def initialize
    @ctx = nil
  end

  def report(ctx)
    @ctx = ctx
  end

  attr_reader :ctx
end

class MockController
  def self.prepend_before_action(*)
  end

  attr_accessor :request

  def initialize(request)
    @request = request
  end

  def action_name
    "stubbed"
  end

  def context
    @request.env[Slimy::Rack::SLIMiddleware::MIDDLEWARE_CONTEXT_KEY]
  end
end

class MockRequest
  attr_accessor :env

  def initialize(context)
    @env = {}
    @env[Slimy::Rack::SLIMiddleware::MIDDLEWARE_CONTEXT_KEY] = context
  end
end
