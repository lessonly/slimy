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
    def initialize(start_time: nil, deadline: nil)
      @start_time = start_time || Time.now
      @deadline = deadline
      @result_status = :success
      @end_time = nil
      @tags = {}
    end

    attr_reader :start_time, :end_time


    attr_accessor :tags

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

    def result_error!
      @result_status = :error
    end

    def result_error?
      @result_status == :error
    end

    def result_success!
      @result_status = :success
    end

    def result_success?
      @result_status == :success
    end

    def success?
      result_success? && deadline_success?
    end

    # duration in ms of the event
    def duration
      return -1 unless finished?
      [@end_time - @start_time,0].max * 1000.0
    end

    def deadline_success?
      return true if @deadline.nil? || ! finished?
      duration < @deadline
    end


  end

end