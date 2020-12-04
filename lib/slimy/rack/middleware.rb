module Slimy::Rack
  class SLIMiddleware

    MIDDLEWARE_CONTEXT_KEY="slimy.milddeware.context"

    def initialize(app)
      @app = app
      @reporter = Slimy::Configuration.default.reporter
    end

    def call(env)
      context = Slimy::Context.new(deadline: 200, type: 'rack')
      env[MIDDLEWARE_CONTEXT_KEY] = context
      begin
        response = @app.call(env)
        context.result_error! if response[0] >= 500
      rescue Exception => error
        context.result_error!
        raise error
      ensure
        context.finish
        report(context)
        return response
      end
    end

    def report(context)
      @reporter.report(context) unless @reporter.nil?
    end
  end
end