require 'multi_json'

require 'node_starter/starter'
require 'node_starter/consumer'
require 'node_starter/shutdown_consumer'

module NodeStarter
  # class for receiving start node messages
  class QueueSubscribe
    def initialize
      @consumer = NodeStarter::Consumer.new
      @shutdown_consumer = NodeStarter::ShutdownConsumer.new
    end

    def start_listening
      @consumer.setup
      @shutdown_consumer.setup

      subscribe_stater_queue
      subscribe_killer_queue
    end

    def stop_listening
      @consumer.close_connection
      @shutdown_consumer.close_connection
    end

    private

    def parse(json_body)
      JSON.parse(json_body)
    end

    def parse_build_id(json_body)
      data = JSON.parse(payload)
      delivery_info[:routing_key].to_s.gsub(/^cmd\./, '')
    end

    def subscribe_stater_queue
      @consumer.subscribe do |delivery_info, metadata, payload|
        params = parse(payload)
        NodeStarter.logger.debug("Received START with build_id: #{params[:build_id]}")
        starter = NodeStarter::Starter.new(
          params['build_id'], params['config'], params['enqueue_data'], params['node_api_uri'])

        Thread.new do
          begin
            starter.start_node_process
          rescue => e
            NodeStarter.logger.error e
          end
        end

        @shutdown_consumer.register_node(params['build_id'])
        @consumer.ack(delivery_info)
      end
    end

    def subscribe_killer_queue
      @shutdown_consumer.subscribe do |delivery_info, metadata, payload|
        NodeStarter.logger.debug("Received kill command with #{payload}")

        build_id = parse_build_id payload

        killer = NodeStarter::Killer.new build_id

        Thread.new do
          killer.shutdown
        end

        @shutdown_consumer.ack delivery_info
      end
    end
  end
end
