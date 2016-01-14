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
      node = Node.find_by build_id: @build_id
      node.status = :aborting
      node.save!

      sleep 120 if shutdown_using_api node.uri # TODO: retry logic with increasing interval
      kill_process node.pid if running? node.pid
      force_kill_process node.pid if running? node.pid
    end

    private

    def kill_process(pid)
      NodeStarter.logger.debug("Checking running node to be aborted build_id=#{@build_id}")
      5.times.with_index do |i|
        unless running? pid
          NodeStarter.logger.debug("Node #{@build_id} terminated.")
          break
        end
        NodeStarter.logger.debug("Node #{@build_id} still alive after #{i + 1} attempts")
        Process.kill('INT', pid)
        sleep 300
      end
    end

    def shutdown_using_api(node_uri)
      return false if node_uri.empty?
      NodeStarter.logger.info "Shutting down node using #{node_uri}."
      node_api = NodeApi.new node_uri
      result = node_api.stop
      NodeStarter.logger.info "Shutting down result: #{result}"
      result == Net::HTTPSuccess
    rescue
      false
    end

    def force_kill_process(pid)
      NodeStarter.logger.info("Force killing node #{@build_id}")
      Process.kill('KILL', pid)
    end

    def running?(pid)
      !Sys::ProcTable.ps(pid).nil?
    end
  end
end
