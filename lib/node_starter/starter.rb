require 'node_starter/node_config_store'
require 'node_starter/enqueue_data_store'
require 'node_starter/prepare_binaries'

module NodeStarter
  # class starting uss node process
  class Starter
    attr_reader :build_id, :dir, :pid

    def initialize(build_id, config_values, enqueue_data, scenario_id)
      @node_api_uri = URI.join NodeStarter.config.uss_node[:base_address], "/#{build_id}", '/api'
      @build_id = build_id
      @config_values = config_values
      @enqueue_data = enqueue_data
    end

    def start_node_process
      @dir = Dir.mktmpdir("uss_node_#{@build_id}_")

      NodeStarter::NodeConfigStore.write_complete_file(dir, @config_values)
      NodeStarter::EnqueueDataStore.write_to(dir, @enqueue_data)
      NodeStarter::PrepareBinaries.write_to(dir)

      start
    end

    private

    def start
      node = Node.create!(
        build_id: @build_id,
        path: @dir,
        status: :created,
        uri: @node_api_uri
      )
      node.save!

      NodeStarter.logger.debug("starting node: #{node}")

      dir = node.path
      node_executable_path = File.join(dir, NodeStarter.config.node_binary_name)

      command = "#{node_executable_path} --start -e #{dir}/enqueueData.bin -c #{dir}/config.xml"
      pid = Process.spawn({}, command)

      NodeStarter.logger.info("Node #{node.build_id} spawned in #{dir} with pid #{pid}")

      node.status = :running
      node.pid = pid
      node.save!

      Process.wait(pid)
      clean_up
    end

    def clean_up
      NodeStarter.logger.info("Cleaning up node #{@build_id} spawned in #{@dir}")
    end
  end
end
