require 'bunny'

module NodeStarter
  class ReportingPublisher
    def setup
      @conn = Bunny.new(
        hostname: NodeStarter.config.amqp.host,
        port:     NodeStarter.config.amqp.port,
        username: NodeStarter.config.amqp.username,
        password: NodeStarter.config.amqp.password,
        vhost:    NodeStarter.config.amqp.vhost)

      @conn.start

      @channel = @conn.create_channel

      exchange_params = {
        durable: true,
        auto_delete: false
      }

      @exchange = @channel.topic(NodeStarter.config.amqp.build_reporting_exchange, exchange_params)
    end

    def receive
      @exchange.publish(NodeStarter.config.amqp.build_receive_message_type || 'build:receive')
    end

    def start
      @exchange.publish(NodeStarter.config.amqp.build_start_message_type || 'build:start')
    end
  end
end
