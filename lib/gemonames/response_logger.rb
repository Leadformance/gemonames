module Gemonames
  class ResponseLogger < Faraday::Response::Middleware
    def initialize(app, logger)
      super(app)
      @logger = logger
    end

    def on_complete(env)
      @logger.info %Q{[Gemonames] method=#{env.method.upcase} status=#{env.status} url="#{env.url}"}
    end
  end
end
