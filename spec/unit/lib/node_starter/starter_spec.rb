describe NodeStarter::Starter do
  let(:subject) do
    NodeStarter::Starter.new('1', {}, nil, 'foo')
  end

  let(:fake_node) { build :node, path: 'bar', build_id: 123 }

  describe '#start_node_process' do
    before(:each) do
      allow(NodeStarter::PrepareBinaries).to receive(:write_to)
      allow(NodeStarter::NodeConfigStore).to receive(:write_complete_file)
      allow(NodeStarter::EnqueueDataStore).to receive(:write_to)
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
    it 'copies log file to artifact storage' do
      expect(Dir).to receive(:mktmpdir) { '/foo' }
      fake_config = { uss_node: { artifact_storage_path: '/bar'} }
      expect(NodeStarter).to receive(:config) { fake_config }
      expected_source = '/foo/debug.log'
      expected_target = "/bar/#{fake_node.build_id}/debug.log"
      expect(FileUtils).to receive(:cp).with(expected_source, expected_target)
    end
    it 'deletes working folder after test' do
      allow(Process).to receive(:spawn) { 123 }
      allow(Process).to receive(:wait)
      expected_dir = 'foo/bar'
      expect(Dir).to receive(:mktmpdir) { expected_dir }
      expect(FileUtils).to receive(:rm_rf).with expected_dir
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
