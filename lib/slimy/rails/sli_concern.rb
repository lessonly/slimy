module Slimy::Rails

  module SLITools extend ActiveSupport::Concern

    included do

      # class-level meta commands
      def self.sli_tag(tag, value, except: nil, only: nil)
        self.before_action only: only, except: except do
          add_sli_tag(tag,value)
        end
      end

      def self.sli_ignore(except: nil, only: nil)
        self.before_action only: only, except: except do
          add_sli_ignore
        end
      end

      def self.sli_deadline(deadline, except: nil, only: nil)
        self.before_action only: only, except: except do
          add_sli_deadline(deadline)
        end
      end

      # helpers
      def slimy_context
        request.env[Slimy::Rack::SLIMiddleware::MIDDLEWARE_CONTEXT_KEY]
      end

      def add_sli_tag(tag,value)
        ctx = slimy_context
        ctx.tags[tag] = value unless ctx.nil?
      end

      def add_sli_ignore
        ctx = slimy_context
        ctx.do_not_report! unless ctx.nil?
      end

      def add_sli_deadline(deadline)
        ctx = slimy_context
        ctx.deadline = deadline unless ctx.nil?
      end
    end
  end
end