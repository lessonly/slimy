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
    @app500 = ->(_env) { [500, { "Content-Type" => "text/plain" }, ["error"]] }
  end

  def teardown
    Timecop.return
  end

  def middleware(app)
    mw = Slimy::Rack::SLIMiddleware.new(app, reporter: @reporter)
    Rack::Lint.new(mw)
  end

  def request(app)
    req = Rack::MockRequest.new(middleware(app))
    req.get("/", "REMOTE_ADDR" => "127.0.0.1")
  end

  def test_rack_request
    res = request(@app)
    assert_equal(res.status, 200)
    assert_equal(res.body, "hello")
    assert(@reporter.ctx.success?, "SLI metric should be successful")
  end

  def test_slow_rack_request
    res = request(@app_slow)
    assert_equal(res.status, 200)
    assert_equal(res.body, "hello")
    refute(@reporter.ctx.success?, "SLI metric should be a failure")
  end

  def test_5xx_rack_request
    res = request(@app500)
    assert_equal(res.status, 500)
    assert_equal(res.body, "error")
    refute(@reporter.ctx.success?, "SLI metric should be a failure")
  end

  def test_error_rack_request
    assert_raises ArgumentError do
      request(@app_error)
    end
    refute(@reporter.ctx.success?, "SLI metric should be a failure")
  end
end
