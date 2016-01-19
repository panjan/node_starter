describe NodeStarter::NodeApi do
  let(:base_uri) { URI('http://foo:1234/api') }
  let(:subject) { NodeStarter::NodeApi.new base_uri }

  describe '#stop' do
    it 'resolves correct host' do
      expect(Net::HTTP).to receive(:start)
                            .with(base_uri.hostname, base_uri.port)
      subject.stop 'goldilocks'
    end

    it 'resolves correct address' do
      request = double(:request, { body: {} })
      expected_uri = 'http://foo:1234/api/v2/shutdown'
      actual_uri = nil
      request = double(:request)
      allow(request).to receive :body=
      expect(Net::HTTP).to receive(:start)
      Net::HTTP::Post.stub(:new) do |uri, _|
        actual_uri = uri
        request
      end
      subject.stop 'goldilocks'
      expect(actual_uri.to_s).to eq expected_uri
    end

    it 'sends stopped_by in request body' do
      fail NotImplementedError
    end
  end
end
