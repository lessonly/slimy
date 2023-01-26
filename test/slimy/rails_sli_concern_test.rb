# frozen_string_literal: true

require "rack/mock"
require "active_support/concern"
require "test_helper"

class NonTaggedController < MockController
  include Slimy::Rails::SLITools
end

class BaseController < MockController
  include Slimy::Rails::SLITools
end

class AuthController < BaseController
end

class UserController < BaseController
end

class RailsSLIConcernTest < Minitest::Test
  def context
    Slimy::Context.new(deadline: 400)
  end

  def request
    MockRequest.new(context)
  end

  def test_new_non_tagged_controller_works
    con = NonTaggedController.new(request)
    assert_nil(con.context.tags[:functional_area])
    assert_equal(con.context.deadline, 400)
    assert(con.context.reportable?)
  end

  def test_add_sli_tag_works
    con = NonTaggedController.new(request)
    con.add_sli_tag(:functional_area, "sessions")
    assert_equal(con.context.tags[:functional_area], "sessions")
  end

  def test_add_sli_ignore_works
    con = NonTaggedController.new(request)
    con.add_sli_ignore
    refute(con.context.reportable?)
  end

  def test_add_sli_deadline_works
    con = NonTaggedController.new(request)
    con.add_sli_deadline(350)
    assert_equal(con.context.deadline, 350)
  end

  def test_class_sli_tag_works
    AuthController.sli_tag(:functional_area, "authentication")
    UserController.sli_tag(:functional_area, "users")
    # Testing no threading or cross class issues
    BaseController.sli_tag(:functional_area, "unset")

    auth_con = AuthController.new(request)
    auth_con.add_sli_tag_functional_area
    user_con = UserController.new(request)
    # Test No Crossover Between Classes
    user_con.add_sli_tag_functional_area
    auth_con.add_sli_tag_functional_area

    assert_equal(auth_con.context.tags[:functional_area], "authentication")
    assert_equal(user_con.context.tags[:functional_area], "users")
  end

  def test_class_sli_tags_works
    AuthController.sli_tags({ :functional_area => "authentication", :team => "auth" })
    BaseController.sli_tag(:functional_area, "unset")

    auth_con = AuthController.new(request)
    auth_con.add_sli_tags
    # Idempotent
    auth_con.add_sli_tags

    assert_equal(auth_con.context.tags[:functional_area], "authentication")
    assert_equal(auth_con.context.tags[:team], "auth")
  end

  def test_prepend
    auth_spy = Spy.on(AuthController, :prepend_before_action)
    base_spy = Spy.on(BaseController, :prepend_before_action)

    AuthController.sli_tags({ :functional_area => "authentication", :team => "auth" })
    BaseController.sli_tag(:functional_area, "unset")
    AuthController.sli_deadline(600)
    BaseController.sli_ignore

    assert_equal(auth_spy.calls.count, 2)
    assert_equal(base_spy.calls.count, 2)
    assert(auth_spy.has_been_called_with?(:add_sli_tags, only: nil, except: nil))
    assert(base_spy.has_been_called_with?(:add_sli_ignore, only: nil, except: nil))
    assert(auth_spy.has_been_called_with?(:sli_deadline, only: nil, except: nil))
  end
end
