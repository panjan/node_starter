describe NodeStarter::ReportingPublisher do
  let(:subject) { NodeStarter::ReportingPublisher.new }
  let(:connection) { double(:connection) }
  let(:channel) { double(:channel) }
  let(:dummy_host) { 'foo' }
  let(:dummy_port) { 156_72 }
  let(:dummy_username) { 'guest' }
  let(:dummy_pass) { 'guest' }
  let(:dummy_vhost) { '/' }
  let(:dummy_queue) { 'test-queue' }
  let(:config) { double(:config, rabbit_reporting_exchange) }

  before do
    allow(connection).to receive(:start)
    allow(connection).to receive(:create_channel)
    allow(NodeStarter).to receive_message_chain(:config, :amqp).and_return(
                            double(
                              'amqp_config',
                              host:     dummy_host,
                              port:     dummy_port,
                              username: dummy_username,
                              password: dummy_pass,
                              vhost:    dummy_vhost))
    allow(NodeStarter).to receive_message_chain(:config, :rabbit_reporting).and_return(
                            'foo:bar'
                          )
  end

  describe '#setup' do
    it 'starts connection to rabbit' do
      expect(Bunny).to receive(:new).with(
                         hostname: dummy_host,
                         port:     dummy_port,
                         username: dummy_username,
                         password: dummy_pass,
                         vhost:    dummy_vhost
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
