require 'sys/proctable'
require 'node_starter/node_api'

module NodeStarter
  # class killing running node process
  class Killer
    attr_reader :build_id

    def initialize(build_id)
      @build_id = build_id
    end

    def shutdown
      NodeStarter.logger.info("Shutting down node #{@build_id}...")
      sleep 50 if shutdown_using_api
      try_kill_process
    end

    private

    def try_kill_process
      NodeStarter.logger.debug("Checking running node to be aborted build_id=#{@build_id}")
      node = Node.find_by build_id: @build_id
      5.times.with_index do |i|
        if !running?(node.pid)
          NodeStarter.logger.debug("Node #{@build_id} finished correctly")
          node.killed = false
          node.finished_at = DateTime.now
          node.status = 'finished'
          node.save!
        end
        NodeStarter.logger.debug("Node #{@build_id} still alive after #{i + 1} attempts")
        Process.kill('INT', node.pid)
        sleep 10
      end

      shutdown_process(node) if running? node.pid
    end

    def shutdown_using_api
      guid = '' # TODO
      base_uri = URI("http://localhost:8732/#{guid}/api")
      node_api = NodeApi.new base_uri
      node_api.stop == Net::HTTPSuccess
    rescue
      false
    end

    def shutdown_process(node)
      node.killed = true
      node.finished_at = DateTime.now
      node.status = 'finished'
      node.save!

      NodeStarter.logger.info("Force killing node #{@build_id}")
      Process.kill('KILL', node.pid)
      sleep 10
      if running?(node.pid)
        NodeStarter.logger.warn("Node #{@build_id} was not killed.")
      end
    end

    def running?(pid)
      !Sys::ProcTable.ps(pid).nil?
    end
  end
end
