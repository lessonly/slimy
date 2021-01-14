# frozen_string_literal: true

require "test_helper"
require "sidekiq"
require "slimy/sidekiq/middleware"

class TimecopWorker
  include Sidekiq::Worker
  def perform(time)
    Timecop.freeze(Time.now + time)
  end
end

class OverrideWorker
  include Sidekiq::Worker

  attr_accessor :sli_tags
  attr_accessor :sli_deadline

  def initialize(tags = {}, deadline = 1000)
    @sli_tags = tags
    @sli_deadline = deadline
  end

  def perform(time)
    Timecop.freeze(Time.now + time)
  end
end

class ExceptionWorker
  include Sidekiq::Worker
  def perform
    raise StandardError
  end
end

class SidekiqMiddlewareTest < Minitest::Test
  def setup
    @reporter = DummyReporter.new
  end

  def teardown
    Timecop.return
  end

  def middleware(opts = {})
    opts.merge!(reporter: @reporter)
    Slimy::Sidekiq::SLIMiddleware.new(opts)
  end

  def test_job_sli_success
    middleware.call(TimecopWorker.new, {}, "default") do
      TimecopWorker.new.perform(0.1)
    end
    assert(@reporter.ctx.success?, "SLI metric should be successful")
  end

  def test_job_default_deadline_slow
    middleware.call(TimecopWorker.new, {}, "default") do
      TimecopWorker.new.perform(0.3)
    end
    refute(@reporter.ctx.success?, "SLI metric should be a failure")
  end

  def test_job_exception_sli_failure
    assert_raises StandardError do
      middleware.call(TimecopWorker.new, {}, "default") do
        ExceptionWorker.new.perform
      end
    end
    refute(@reporter.ctx.success?, "SLI metric should be a failure")
  end

  def test_job_override_deadline_success
    worker = OverrideWorker.new
    worker.sli_deadline = 600
    middleware.call(worker, {}, "default") do
      worker.perform(0.5)
    end
    assert(@reporter.ctx.success?, "SLI metric should be successful")
  end

  def test_job_override_deadline_failuire
    worker = OverrideWorker.new
    worker.sli_deadline = 800
    middleware.call(worker, {}, "default") do
      worker.perform(0.9)
    end
    refute(@reporter.ctx.success?, "SLI metric should be a failure")
  end

  def test_job_override_tags
    worker = OverrideWorker.new
    worker.sli_tags = { team: "team1" }
    middleware.call(worker, {}, "default") do
      worker.perform(0.9)
    end

    assert(
      @reporter.ctx.tags[:team] == "team1",
      "SLI context should allow tag override"
    )
  end

  def test_default_queue_deadline_success
    mw = middleware(deadlines: { custom_queue: 2000 })
    mw.call(TimecopWorker.new, {}, "custom_queue") do
      TimecopWorker.new.perform(1.9)
    end
    assert(@reporter.ctx.success?, "SLI metric should be successful")
  end

  def test_default_queue_deadline_failure
    mw = middleware(deadlines: { custom_queue: 2000 })
    mw.call(TimecopWorker.new, {}, "custom_queue") do
      TimecopWorker.new.perform(2.1)
    end
    refute(@reporter.ctx.success?, "SLI metric should be a failure")
  end
end
