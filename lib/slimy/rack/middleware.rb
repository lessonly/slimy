module Slimy::Rack
  class SLIMiddleware
    def initialize(app)
      @app = app
      @reporter = Slimy::Reporters::RailsLogReporter.new
    end

    def call(env)
      context = Slimy::Context.new(deadline: 200)
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