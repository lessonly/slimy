module Slimy::Reporters
  class DatadogReporter < BaseReporter

    def initialize(dogstatsd)
      @dogstatsd = dogstatsd
    end

    def report(context)
      return unless context.reportable?

      current_span = Datadog.tracer.active_span
      unless current_span.nil?
        sli_status =(context.success? ? "success" : "failure")
        current_span.set_tag('sli_status', sli_status)
        current_span.set_tag('sli_deadline', context.deadline)
        context.tags.each_pair do |key, value|
          current_span.set_tag(key,value)
        end
        @dogstatsd.increment("sli.#{context.type}.#{sli_status}", tags: context.tags)
      else
        Rails.logger.debug("COULD  NOT FIND SPAN")
      end
    end
  end
end