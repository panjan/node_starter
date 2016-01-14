require 'multi_json'

require 'node_starter/starter'
require 'node_starter/consumer'
require 'node_starter/cmd_consumer'

module NodeStarter
  # class for receiving start node messages
  class QueueSubscribe
    def initialize
      @consumer = NodeStarter::Consumer.new
      @cmd_consumer = NodeStarter::CmdConsumer.new
    end

    def start_listening
      @consumer.setup
      @cmd_consumer.setup

      subscribe_stater_queue
      subscribe_cmd_queue
    end

    def close_connection
      @consumer.close_connection
      @cmd_consumer.close_connection
    end

    private

    def parse(json_body)
      JSON.parse(json_body)
    end

    def parse_build_id(json_body)
      data = JSON.parse(payload).to_hash
      delivery_info[:routing_key].to_s.gsub(/^cmd\./,'')
    end

    def subscribe_stater_queue
      @consumer.subscribe do |delivery_info, metadata, payload|
        NodeStarter.logger.debug("Received START with #{payload}")

        params = parse(payload)

        starter = NodeStarter::Starter.new(
          params['build_id'], params['config'], params['enqueue_data'])

        Thread.new do
          starter.schedule_spawn_process
        end

        @cmd_consumer.register_node(notification_build_id)
        @consumer.ack(delivery_info)
      end
    end

    def subscribe_cmd_queue
      @cmd_consumer.subscribe do |delivery_info, metadata, payload|
        NodeStarter.logger.debug("Received CMD with #{payload}")

        build_id = parse_build_id(payload)

        aborter = NodeStarter::Aborter.new(build_id)

        Thread.new do
          aborter.abort_process
        end

        @cmd_consumer.ack(delivery_info)
      end
    end
  end
end
