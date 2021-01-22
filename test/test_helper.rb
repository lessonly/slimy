# frozen_string_literal: true

require "minitest/autorun"
require "slimy"
require "timecop"

def freeze_ms(duration_ms)
  Timecop.freeze(Time.now + (duration_ms / 1000.0)) do
    yield
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
