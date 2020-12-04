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
      response = nil
      begin
        response = @app.call(env)
        context.result_error! if response[0] >= 500
      rescue StandardError => e
        context.result_error!
        raise e
      ensure
        context.finish
        report(context)
      end
      response
    end

    def report(context)
      @reporter&.report(context)
    end
  end
end