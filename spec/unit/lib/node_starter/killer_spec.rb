describe NodeStarter::Killer do
  let!(:node) { create :node, build_id: 123, pid: 1 }
  let(:subject) { NodeStarter::Killer.new 123 }
  let!(:node_api) { double 'foo' }

  describe '#shutdown' do
    before do
      allow(subject). to receive(:sleep) { puts 'sleep' }
    end

    after do
      Node.delete_all
    end

    context 'node api responding' do
      it 'stops node using api' do
        allow(Sys::ProcTable).to receive(:ps) { nil }
        expect(node_api).to receive(:stop) { Net::HTTPSuccess }
        expect(NodeStarter::NodeApi).to receive(:new) { node_api }
        subject.shutdown
        node.reload
        expect(node.killed).to be false
        expect(node.status).to eq 'finished'
      end
    end

    context 'node api not responding' do
      it 'kills node process' do
        allow(Sys::ProcTable).to receive(:ps) { true }
        expect(node_api).to receive(:stop) { Net::HTTPSuccess }
        expect(NodeStarter::NodeApi).to receive(:new) { node_api }
        expect(Process).to receive(:kill).with('INT', 1).exactly(5).times
        expect(Process).to receive(:kill).with('KILL', 1).exactly(1).times
        subject.shutdown
        node.reload
        expect(node.killed).to be true
        expect(node.status).to eq 'finished'
      end
    end
  end
end
