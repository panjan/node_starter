describe NodeStarter::Killer do
  let(:node) { create :node, build_id: 123 }
  let(:subject) { NodeStarter::Killer.new node.build_id }

  describe '#abort_process' do
    before do
      allow(subject). to receive(:sleep) { puts 'sleep' }
    end

    context 'node responding' do
      it 'stops node regularly' do
        subject.abort_process
      end
    end

    context 'node not responding' do
      it 'kills node process' do
        
      end
    end
  end
end
