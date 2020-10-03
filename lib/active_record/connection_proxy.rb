require "active_record/connection_proxy/version"

module ActiveRecord
  class ConnectionProxy
    attr_reader :connection

    def initialize(connection:, klass:)
      @connection = connection
      @klass = klass
    end

    def ==(*args)
      method_missing(:==, *args)
    end

    def method_missing(method_name, *args, &block)
      result = @klass.__send__(method_name, *args, &block)
      if result.respond_to?(:all)
        Proxy.new(
          connection: @connection,
          klass: result
        )
      else
        result
      end
    end

    def respond_to_missing?(method_name, *args, &block)
      @klass.__send__(:respond_to_missing?, method_name, *args, &block)
    end
  end
end
