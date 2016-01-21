describe NodeStarter::QueueSubscribe do
  let(:subject) { NodeStarter::QueueSubscribe.new }
  let(:consumer) do
    double('consumer',
           setup: {},
           subscribe: {},
           close_connection: {})
  end
  let(:shutdown_consumer) do
    double('shutdown_consumer',
           setup: {},
           subscribe: {},
           close_connection: {})
  end

  before do
    allow(NodeStarter::Consumer).to receive(:new) { consumer }
    allow(NodeStarter::ShutdownConsumer).to receive(:new) { shutdown_consumer }
  end

  describe '#initialize' do
    it 'creates starter consumer' do
      expect(NodeStarter::Consumer).to receive :new
      NodeStarter::QueueSubscribe.new
    end

    it 'creates cmd consumer' do
      expect(NodeStarter::ShutdownConsumer).to receive :new
      NodeStarter::QueueSubscribe.new
    end
  end

  describe '#start_listening' do
    it 'sets consumer up' do
      expect(consumer).to receive :setup
      subject.start_listening
    end

    it 'sets shutdown_consumer up' do
      expect(shutdown_consumer).to receive :setup
      subject.start_listening
    end

    it 'subscribes to starter queue' do
      expect(consumer).to receive :subscribe
      subject.start_listening
    end

    it 'subscribes to cmd queue' do
      expect(shutdown_consumer).to receive :subscribe
      subject.start_listening
    end
  end

  describe '#stop_listening' do
    it 'closes consumer connection' do
      expect(consumer).to receive :close_connection
      subject.stop_listening
    end

    it 'closes cmd consumer connection' do
      expect(shutdown_consumer).to receive :close_connection
      subject.stop_listening
    end
  end
end
