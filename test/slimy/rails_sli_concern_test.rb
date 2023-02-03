# frozen_string_literal: true

require "rack/mock"
require "active_support/concern"
require "test_helper"

# Tests Classes
class NonTaggedController < MockController
  include Slimy::Rails::SLITools
end

class BaseController < MockController
  include Slimy::Rails::SLITools
end

class RailsSLIConcernTest < Minitest::Test
  def context
    Slimy::Context.new(deadline: 400)
  end

  def request
    MockRequest.new(context)
  end

  # Create dynamic runtime class constants to reduce boilerplate
  def create_klass(name_const, parent_klass)
    Object.const_set(name_const, create_class(parent_klass))
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
    create_klass("RootController", BaseController)
    create_klass("AuthController", RootController)
    create_klass("UserController", RootController)
    AuthController.sli_tag(:functional_area, "authentication")
    UserController.sli_tag(:functional_area, "users")
    # Testing no threading or cross class issues
    RootController.sli_tag(:functional_area, "unset")

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
    create_klass("ApplicationController", BaseController)
    create_klass("AuthorizationController", ApplicationController)
    AuthorizationController.sli_tags({ :functional_area => "authorization", :team => "auth" })
    ApplicationController.sli_tag(:functional_area, "unset")

    auth_con = AuthorizationController.new(request)
    auth_con.add_sli_tags
    # Idempotent
    auth_con.add_sli_tags

    assert_equal(auth_con.context.tags[:functional_area], "authorization")
    assert_equal(auth_con.context.tags[:team], "auth")
  end

  def test_prepend
    create_klass("AppController", BaseController)
    create_klass("GroupController", AppController)
    group_spy = Spy.on(GroupController, :prepend_before_action)
    app_spy = Spy.on(AppController, :prepend_before_action)

    GroupController.sli_tags({ :functional_area => "groups", :team => "people" })
    AppController.sli_tag(:functional_area, "unset")
    GroupController.sli_deadline(600)
    AppController.sli_ignore

    assert_equal(group_spy.calls.count, 2)
    assert_equal(app_spy.calls.count, 2)
    assert(group_spy.has_been_called_with?(:add_sli_tags, only: nil, except: nil))
    assert(app_spy.has_been_called_with?(:add_sli_ignore, only: nil, except: nil))
    assert(group_spy.has_been_called_with?(:sli_deadline, only: nil, except: nil))
  end
end
