# frozen_string_literal: true

module Slimy
  module Reporters
    # Reporter for sending data to datadog
    #
    # this requires a DogstatsD instance to operate
    #
    class DatadogReporter < BaseReporter
      def initialize(dogstatsd)
        @dogstatsd = dogstatsd
      end

      # report the given context to datadog
      def report(context)
        return unless context.reportable?

        sli_status = (context.success? ? "success" : "failure")
        current_span = Datadog.tracer.active_span
        unless current_span.nil?
          set_tags_on_span(context, sli_status, current_span)
          @dogstatsd.increment("sli.#{context.type}.#{sli_status}",
                               tags: context.tags)
        end
      end

      def set_tags_on_span(context, sli_status, current_span)
        current_span.set_tag("sli_status", sli_status)
        current_span.set_tag("sli_deadline", context.deadline)
        context.tags.each_pair do |key, value|
          current_span.set_tag(key, value)
        end
      end
    end
  end
end
