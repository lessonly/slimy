# frozen_string_literal: true

require "test_helper"

class ContextTest < Minitest::Test
  def test_that_context_new_works
    context = Slimy::Context.new
    refute_nil context
    refute context.finished?
  end

  def test_finish_exceeds_deadline
    context = Slimy::Context.new(deadline: 20)

    freeze_ms(30) do
      context.finish
      assert context.finished?
      refute context.deadline_success?, "duration: #{context.duration} should be less than 20"
      assert context.result_success?
      refute context.success?
    end
  end

  def test_finish_within_deadline
    context = Slimy::Context.new(deadline: 200)

    freeze_ms(100) do
      context.finish
      assert context.finished?
      assert context.deadline_success?
      assert context.result_success?
      assert context.success?
    end
  end

  def test_error_finish_within_deadline
    context = Slimy::Context.new(deadline: 200)

    freeze_ms(100) do
      context.result_error!
      context.finish
      assert context.finished?
      assert context.deadline_success?
      refute context.result_success?
      refute context.success?
    end
  end
end
