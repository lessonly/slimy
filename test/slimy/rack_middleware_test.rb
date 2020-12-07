# frozen_string_literal: true
require "rack/mock"
require "test_helper"

class ContextTest < Minitest::Test
  def setup
    @reporter = DummyReporter.new
    @app = ->(_env) { [200, { "Content-Type" => "text/plain" }, ["hello"]] }
    @app_slow = lambda do |_env|
      Timecop.freeze(Time.now + 1990)
      [200, { "Content-Type" => "text/plain" }, ["hello"]]
    end
    @app_error = ->(_env) { raise ArgumentError }
    @app500 = ->(_env) { [500, { "Content-Type" => "text/plain" }, ["hello"]] }
  end

  def middleware(app)
    mw = Slimy::Rack::SLIMiddleware.new(app, reporter: @reporter)
    Rack::Lint.new(mw)
  end

  def test_rack_request
    req = Rack::MockRequest.new(middleware(@app))
    res = req.get("/", "REMOTE_ADDR" => "127.0.0.1")
    assert_equal(res.status, 200)
    assert_equal(res.body, "hello")
    assert(@reporter.ctx.success?, "SLI metric should be successful")
  end

  def test_slow_rack_request
    req = Rack::MockRequest.new(middleware(@app_slow))
    res = req.get("/", "REMOTE_ADDR" => "127.0.0.1")
    assert_equal(res.status, 200)
    assert_equal(res.body, "hello")
    refute(@reporter.ctx.success?, "SLI metric should be a failure")
    Timecop.return
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
