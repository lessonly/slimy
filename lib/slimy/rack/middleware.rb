# frozen_string_literal: true

module Slimy::Rack
  class SLIMiddleware
    MIDDLEWARE_CONTEXT_KEY = "slimy.milddeware.context"

    def initialize(app, options = {})
      @app = app
      @reporter = if options.key? :reporter
                    options[:reporter]
                  else
                    Slimy::Configuration.default.reporter
                  end
    end

    def call(env)
      context = Slimy::Context.new(deadline: 200, type: "rack")
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
