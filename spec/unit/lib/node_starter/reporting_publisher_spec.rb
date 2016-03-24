describe NodeStarter::ReportingPublisher do
  let(:subject) { NodeStarter::ReportingPublisher.new }
  let(:connection) { double(:connection) }
  let(:channel) { double(:channel) }
  let(:config) do
    double('config', rabbit_reporting: double('rabbit',
                                              host:     'foo',
                                              port:     123_456,
                                              username: 'neo',
                                              password: 'bar',
                                              vhost:    'baz',
                                              build_reporting_exchange: 'qux'))
  end
  before do
    allow(connection).to receive(:start)
    allow(connection).to receive(:create_channel)
    allow(channel).to receive(:topic) { double('topic', :publish) }
    allow(NodeStarter).to receive(:config).and_return(config)
  end

  describe '#setup' do
    it 'starts connection to rabbit' do
      expect(Bunny).to receive(:new).with(hostname: config.rabbit_reporting.host,
                                          port:     config.rabbit_reporting.port,
                                          username: config.rabbit_reporting.username,
                                          password: config.rabbit_reporting.pass,
                                          vhost:    config.rabbit_reporting.vhost
                                         ) do
        connection
      end
      subject.setup
    end

    it 'creates an exchange for reporting' do
      fail
    end
  end

  describe '#receive' do
    it 'publishes receive message' do
      fail
    end
  end

  describe '#start' do
    it 'publishes start message' do
      fail
    end
  end
end
