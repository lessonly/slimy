# frozen_string_literal: true

module Slimy
  module Rails
    # SLITools concern
    #
    # This module adds Controller helpers for instrumenting SLIs
    #
    module SLITools
      extend ActiveSupport::Concern
      included do
        # class-level meta commands
        def self.sli_tag(tag, value, except: nil, only: nil)
          undef_method("add_sli_tag_#{tag}") if method_defined?("add_sli_tag_#{tag}")
          define_method("add_sli_tag_#{tag}") do
            add_sli_tag(tag, value)
          end

          prepend_before_action :"add_sli_tag_#{tag}", only: only, except: except
        end

        def self.sli_tags(tags, except: nil, only: nil)
          undef_method("add_sli_tags") if method_defined?("add_sli_tags")
          define_method("add_sli_tags") do
            tags.each_pair do |tag, value|
              add_sli_tag(tag, value)
            end
          end

          prepend_before_action :add_sli_tags, only: only, except: except
        end

        def self.sli_ignore(except: nil, only: nil)
          prepend_before_action :add_sli_ignore, only: only, except: except
        end

        def self.sli_deadline(deadline, except: nil, only: nil)
          undef_method("sli_deadline") if method_defined?("sli_deadline")
          define_method("sli_deadline") do
            add_sli_deadline(deadline)
          end
          prepend_before_action :sli_deadline, only: only, except: except
        end

        prepend_before_action do
          add_sli_tag("controller", self.class.name)
          add_sli_tag("action", action_name)
        end

        # helpers
        def slimy_context
          request.env[Slimy::Rack::SLIMiddleware::MIDDLEWARE_CONTEXT_KEY]
        end

        def add_sli_tag(tag, value)
          ctx = slimy_context
          ctx.tags[tag] = value unless ctx.nil?
        end

        def add_sli_ignore
          ctx = slimy_context
          ctx&.do_not_report!
        end

        def add_sli_deadline(deadline)
          ctx = slimy_context
          ctx.deadline = deadline unless ctx.nil?
        end
      end
    end
  end
end
