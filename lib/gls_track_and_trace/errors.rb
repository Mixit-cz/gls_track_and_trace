module GlsTrackAndTrace

  class RequestError < StandardError
    attr_reader :code

    def initialize(message, code=nil);
      super message
      @code = code
    end

  end

  class AuthenticationError < RequestError
  end

  class NoDataFoundError < RequestError
  end

end
