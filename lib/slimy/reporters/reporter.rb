module Slimy::Reporters

  class BaseReporter

    def report(context)
      raise NotImplementedError
    end
  end
end