# frozen_string_literal: true

require "test_helper"
require "sidekiq"
require "slimy/sidekiq/middleware"

class SidekiqMiddlewareTest < Minitest::Test
  OVERRIDE_DEADLINE = 1000

  class BasicWorker
    include Sidekiq::Worker
    def perform(time)
      Timecop.freeze(Time.now + time)
    end
  end

  class OverrideWorker
    include Sidekiq::Worker
    sidekiq_options sli_tags: { tag1: "value1" },
                    sli_deadline: OVERRIDE_DEADLINE

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
    middleware.call(OverrideWorker.new, {}, "default") do
      OverrideWorker.new.perform(DEFAULT_DEADLINE - 0.1)
    end
    assert(@reporter.ctx.success?, "SLI metric should be successful")
  end

  def test_job_default_deadline_slow
    middleware.call(BasicWorker.new, {}, "default") do
      BasicWorker.new.perform(DEFAULT_DEADLINE + 0.1)
    end
    refute(@reporter.ctx.success?, "SLI metric should be a failure")
  end

  def test_job_exception_sli_failure
    assert_raises StandardError do
      middleware.call(OverrideWorker.new, {}, "default") do
        ExceptionWorker.new.perform
      end
    end
    refute(@reporter.ctx.success?, "SLI metric should be a failure")
  end

  def test_job_override_deadline_success
    worker = OverrideWorker.new
    middleware.call(worker, {}, "default") do
      worker.perform(OVERRIDE_DEADLINE - 0.1)
    end
    assert(@reporter.ctx.success?, "SLI metric should be successful")
  end

  def test_job_override_deadline_failuire
    worker = OverrideWorker.new
    middleware.call(worker, {}, "default") do
      worker.perform(OVERRIDE_DEADLINE + 0.1)
    end
    refute(@reporter.ctx.success?, "SLI metric should be a failure")
  end

  def test_job_override_tags
    worker = OverrideWorker.new
    middleware.call(worker, {}, "default") do
      worker.perform(OVERRIDE_DEADLINE - 0.1)
    end

    assert(
      @reporter.ctx.tags[:tag1] == "value1",
      "SLI context should allow tag override"
    )
  end

  def test_tags_job_name
    worker = OverrideWorker.new
    middleware.call(worker, {}, "default") do
      worker.perform(OVERRIDE_DEADLINE - 0.1)
    end

    assert(
      @reporter.ctx.tags[:job] == worker.class.name,
      "SLI context tags should include job name"
    )
  end

  def test_default_queue_deadline_success
    mw = middleware(deadlines: { custom_queue: 2000 })
    mw.call(BasicWorker.new, {}, "custom_queue") do
      BasicWorker.new.perform(1.9)
    end
    assert(@reporter.ctx.success?, "SLI metric should be successful")
  end

  def test_default_queue_deadline_failure
    mw = middleware(deadlines: { custom_queue: 2000 })
    mw.call(BasicWorker.new, {}, "custom_queue") do
      BasicWorker.new.perform(2.1)
    end
    refute(@reporter.ctx.success?, "SLI metric should be a failure")
  end
end
