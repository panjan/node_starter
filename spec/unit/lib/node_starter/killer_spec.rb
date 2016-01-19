describe NodeStarter::Killer do
  let(:node) { create :node, build_id: 123 }
  let(:subject) { NodeStarter::Killer.new node.build_id }
  let(:node_api) { NodeStarter::NodeApi.new 'foo' }
  describe '#shutdown' do
    before do
      allow(subject). to receive(:sleep) { puts 'sleep' }
    end

    context 'node api responding' do
      it 'stops node using api' do
        expect(node_api).to receive :stop
        subject.shutdown
        fail NotImplementedError
      end
    end

    context 'node api not responding' do
      it 'kills node process' do
        fail NotImplementedError
      end
    end
  end
end
