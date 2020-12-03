module Slimy

  # Slimy::Context
  #
  # This is a group of metadata that exists for the duration of some request to be measured
  # as part of an SLI.
  #
  class Context

    # Create a new context sets the `start_time` to now
    #
    # == Parameters
    # start_time::
    #   An overriden Time at which the event started.  Defaults to now.
    #
    # deadline::
    #   ms that this context should be finished in to be considered acceptable
    #
    def initialize(start_time: nil, deadline: nil)
      @start_time = start_time || Time.now
      @deadline = deadline
      @result_status = :success
      @end_time = nil
      @tags = {}
      @reportable = true
    end

    attr_reader :start_time, :end_time


    attr_accessor :tags, :deadline

    # Set the end_time value for the context if not already set
    #
    # == Parameters
    # end_time::
    #   An overriden Time at which the event ended.  Defaults to now.
    #
    def finish(end_time: nil)
      @end_time = end_time || Time.now unless finished?
    end

    # Whether or not an end time has been set
    def finished?
      !@end_time.nil?
    end

    # mark request as having an error, or otherwise unacceptable for users
    def result_error!
      @result_status = :error
    end

    # was the result of the request an error?
    def result_error?
      @result_status == :error
    end

    # mark the result as being successful.
    # This will not override deadline failure
    def result_success!
      @result_status = :success
    end

    # Was the execution path of this request normal (not an error)?
    # This does not include deadline failures
    def result_success?
      @result_status == :success
    end

    # Returns true if there was no error and if the deadline was not reached.
    def success?
      result_success? && deadline_success?
    end

    # duration in ms of the event
    def duration
      return -1 unless finished?
      [@end_time - @start_time,0].max * 1000.0
    end

    # Did the request finish before the deadline (or was there no deadline)
    def deadline_success?
      return true if @deadline.nil? || ! finished?
      duration < @deadline
    end

    # Whether or not this context should be reported
    def reportable?
      @reportable
    end

    def don_not_report!
      @reportable = false
    end

    # tool for debugging 
    def debug_format
      "slimy_ctx:\n\tfinished: #{finished?}\n\tduration: #{duration}\n\tresult_success: #{result_success?}\n\tduration_success: #{deadline_success?}\n\tsuccess: #{success?}\n\tdeadline: #{deadline}\n\ttags: #{tags.inspect}"
    end

  end

end