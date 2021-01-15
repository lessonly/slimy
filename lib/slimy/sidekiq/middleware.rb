# frozen_string_literal: true

module Slimy
  module Sidekiq
    # sidekiq middleware for tracking job SLIs
    class SLIMiddleware
      def initialize(opts = {})
        @reporter =
          if opts.key? :reporter
            opts[:reporter]
          else
            Slimy::Configuration.default.reporter
          end
        @default_tags = opts[:tags] || {}
        @default_deadlines = opts[:deadlines] || {}
      end

      def call(worker, _msg, queue)
        context = setup_context(worker, queue)
        begin
          result = yield
        rescue StandardError => e
          context.result_error!
          raise e
        ensure
          context.finish
          report(context)
        end
        result
      end

      def report(context)
        @reporter&.report(context)
      end

      private

      def setup_context(worker, queue)
        ctx = Slimy::Context.new(deadline: 200, type: "sidekiq")
        ctx.tags = @default_tags.merge(queue: queue, job: worker.class.name)
        if worker.respond_to?(:sli_tags) && worker.sli_tags.is_a?(Hash)
          ctx.tags.merge! worker.sli_tags
        end

        if worker.respond_to?(:sli_deadline)
          ctx.deadline = worker.sli_deadline
        elsif @default_deadlines.key?(queue.to_sym)
          ctx.deadline = @default_deadlines[queue.to_sym]
        end

        ctx
      end
    end
  end
end
