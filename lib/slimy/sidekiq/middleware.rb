module Slimy::Sidekiq

  class SLIMiddleware

    def initialize(opts = {})
      @reporter = Slimy::Configuration.default.reporter
      @default_tags = opts[:tags] || {}
      @default_deadlines = opts[:deadlines] || {}
    end

    def call(worker, msg, queue)
      context = setup_context(worker, msg, queue)
      begin
        result = yield
        # todo figure out how to check if job was error?
        # can the job fail/error without raising an exception?
      rescue Exception => error
        context.result_error!
        raise error
      ensure
        context.finish
        report(context)
        return result
      end
    end

    def report(context)
      @reporter.report(context) unless @reporter.nil?
    end

    private

    def setup_context(worker, msg, queue)
      ctx = Slimy::Context.new(deadline: 200, type: 'sidekiq')
      ctx.tags = @default_tags

      if @default_deadlines.key?(queue.to_sym)
        ctx.deadline = @default_deadlines[queue.to_sym]
      end

      if worker.respond_to?(:sli_deadline)
        ctx.deadline = worker.sli_deadline
      end

      if worker.respond_to?(:sli_tags) && worker.sli_tags.is_a? Hash
        ctx.tags.merge! worker.sli_tags
      end

      return ctx
    end
  end
end