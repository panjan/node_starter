require 'sys/proctable'

module NodeStarter
  # class killing running uss node process
  class Aborter
    attr_reader :build_id

    def initialize(build_id)
      @build_id = build_id
    end

    def abort_process
      NodeStarter.logger.info( "Aborting node #{@build_id}")

      send_abort_via_REST
      sleep 50
      check
    end

    private

    def send_abort_via_REST
      #contact uss node rest API and call abort
    end

    def check
      NodeStarter.logger.debug( "Checking running node to be aborted build_id=#{@build_id}")
      node = Node.find(build_id: @build_id)

      if running?(node.pid)

        NodeStarter.logger.debug( "Node #{@build_id} still alive after #{node.abort_attempts} atts")

        node.abort_attempts = 1 + (node.abort_attempts || 0)
        node.save!

        if node.abort_attempts == 5
          node.killed = true;
          node.finished_at = DateTime.now
          node.status = 'finished'
          node.save!

          NodeStarter.logger.info( "Force killing node #{@build_id}")

          Process.kill("INT", node.pid)
          return
        else
          sleep 100
          check
        end
      else
        NodeStarter.logger.debug("Node #{@build_id} finished correctly")

        node.killed = false
        node.finished_at = DateTime.now
        node.status = 'finished'
        node.save!
      end
    end

    def running?(pid)
       !Sys::ProcTable.ps(pid).nil?
    end
  end
end
