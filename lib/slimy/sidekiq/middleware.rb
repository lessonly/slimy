# frozen_string_literal: true

module Slimy
  module Sidekiq
    # sidekiq middleware for tracking job SLIs
    class SLIMiddleware
      DEFAULT_DEADLINE = 200

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
        ctx = Slimy::Context.new(deadline: DEFAULT_DEADLINE, type: "sidekiq")
        set_tags!(ctx, worker, queue)
        set_deadline!(ctx, worker, queue)
        ctx
      end

      def set_tags!(context, worker, queue)
        context.tags = @default_tags.merge(queue: queue, job: worker.class.name)
        worker_tags = worker.class.get_sidekiq_options["sli_tags"]
        return unless !worker_tags.nil? && worker_tags.is_a?(Hash)

        context.tags.merge! worker_tags
      end

      def set_deadline!(context, worker, queue)
        worker_deadline = worker.class.get_sidekiq_options["sli_deadline"]
        if !worker_deadline.nil?
          context.deadline = worker_deadline
        elsif @default_deadlines.key?(queue.to_sym)
          context.deadline = @default_deadlines[queue.to_sym]
        end
      end
    end
  end
end
