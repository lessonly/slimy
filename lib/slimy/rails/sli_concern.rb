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
          before_action only: only, except: except do
            add_sli_tag(tag, value)
          end
        end

        def self.sli_ignore(except: nil, only: nil)
          before_action only: only, except: except do
            add_sli_ignore
          end
        end

        def self.sli_deadline(deadline, except: nil, only: nil)
          before_action only: only, except: except do
            add_sli_deadline(deadline)
          end
        end

        before_action do
          add_sli_tag("controller", controller_name)
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
