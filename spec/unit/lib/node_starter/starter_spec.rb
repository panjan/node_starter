describe NodeStarter::Starter do
  let(:subject) do
    NodeStarter::Starter.new('1', {}, nil, 'foo')
  end

  let(:fake_node) { build :node, path: 'bar' }

  describe '#start_node_process' do
    before(:each) do
      allow(NodeStarter::PrepareBinaries).to receive(:write_to)
      allow(NodeStarter::NodeConfigStore).to receive(:write_complete_file)
      allow(NodeStarter::EnqueueDataStore).to receive(:write_to)
    end

    after do
      FileUtils.rm_rf(subject.dir)
    end
    it 'prepares binaries' do
      expect(NodeStarter::PrepareBinaries).to receive(:write_to)
      allow(subject).to receive(:start).and_return(0)
      subject.start_node_process
    end
    it 'prepares config' do
      expect(NodeStarter::NodeConfigStore).to receive(:write_complete_file)
      allow(subject).to receive(:start).and_return(0)
      subject.start_node_process
    end
    it 'prepares enqueue data' do
      allow(subject).to receive(:start).and_return(0)
      expect(NodeStarter::EnqueueDataStore).to receive(:write_to)
      subject.start_node_process
    end
    it 'creates node record in db' do
      allow(Process).to receive(:spawn) { 123 }
      allow(Process).to receive(:wait)
      expect(Node).to receive(:create!) { fake_node }
      subject.start_node_process
    end
    it 'starts and waits for node process' do
      expect(Process).to receive(:spawn) { 123 }
      expect(Process).to receive(:wait)
      allow(Node).to receive(:create!) { fake_node }
      subject.start_node_process
    end
    it 'updates pid in db' do
      expect(fake_node.pid).to be(-1)
      expected_pid = 123
      allow(Process).to receive(:spawn) { expected_pid }
      allow(Process).to receive(:wait)
      expect(Node).to receive(:create!) { fake_node }
      expect(fake_node).to receive(:save!)
      expect(fake_node).to receive(:save!) do
        expect(fake_node.pid).to eq expected_pid
      end
      subject.start_node_process
    end
  end
end
