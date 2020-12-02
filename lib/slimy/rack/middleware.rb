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
      ensure
        context.finish
        report(context)
      end
    end

    def report(context)
      @reporter.report(context) unless @reporter.nil?
    end
  end
end