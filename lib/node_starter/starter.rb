require 'node_starter/node_config_store'
require 'node_starter/enqueue_data_store'
require 'node_starter/prepare_binaries'

module NodeStarter
  # class starting uss node process
  class Starter
    attr_reader :build_id, :dir, :pid

    def initialize(build_id, config_values, enqueue_data)
      @build_id = build_id
      config_values[:id] = build_id

      config_values[:base_address] ||= NodeStarter.config.uss_node[:base_address] + build_id
      @config_values = NodeStarter.config.uss_node.merge(config_values)
      @enqueue_data = enqueue_data
    end

    def schedule_spawn_process
      @dir = Dir.mktmpdir("uss_node_#{build_id}_")

      NodeStarter::NodeConfigStore.new(@config_values).write_to(dir)
      NodeStarter::EnqueueDataStore.write_to(dir, @enqueue_data)
      NodeStarter::PrepareBinaries.write_to(dir)

      start
    end

    private

    def start
      node = Node.create!(
        build_id: @config_values['id'],
        path: @dir,
        status: :created
      )
      node.save!


      NodeStarter.logge.debug( "starting node: #{node}")

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
      NodeStarter.logger.info("Cleaning up node #{node.build_id} spawned in #{dir}")
    end
  end
end
