require "test_helper"

class SLIContextTest < Minitest::Test

  def test_that_SLIContext_new_works
    context = Slimy::SLIContext.new
    refute_nil context
  end

end