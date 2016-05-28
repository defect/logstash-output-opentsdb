require 'logstash/devutils/rspec/spec_helper'
require 'logstash/outputs/opentsdb'

require_relative '../spec_helper'

describe LogStash::Outputs::Opentsdb do

  before do
    subject.register
    subject.receive event
  end

  subject { LogStash::Outputs::Opentsdb.new(config) }

  context 'single metric, no tags' do
    let(:config) do
      {
        'metrics' => ['metric_1', '%{val}']
      }
    end

    let(:event) { LogStash::Event.new('val' => 123) }

    it 'sends the correct opentsdb format' do
      expect(subject.socket.pop).to match(/^put metric_1 \d+ 123 \n/)
    end
  end

  context 'single metric, multiple tags' do
    let(:config) do
      {
        'metrics' => ['metric_1', '%{val}', 'tag1', '%{tag1}', 'tag2', '%{tag2}']
      }
    end

    let(:event) { LogStash::Event.new('val' => 123, 'tag1' => 'foo', 'tag2' => 'bar') }

    it 'sends the correct opentsdb format' do
      expect(subject.socket.pop).to match(/^put metric_1 \d+ 123 tag1=foo tag2=bar\n/)
    end
  end

  context 'multiple metrics, no tags' do
    let(:config) do
      {
        'metrics' => [
          ['metric_1', '%{val1}'],
          ['metric_2', '%{val2}']
        ]
      }
    end

    let(:event) { LogStash::Event.new('val1' => 123, 'val2' => 456) }

    it 'sends the correct opentsdb format' do
      expect(subject.socket.pop).to match(/^put metric_2 \d+ 456 \n/)
      expect(subject.socket.pop).to match(/^put metric_1 \d+ 123 \n/)
    end
  end

  context 'multiple metrics, multiple tags' do
    let(:config) do
      {
        'metrics' => [
          ['metric_1', '%{val1}', 'footag', '%{tag1}'],
          ['metric_2', '%{val2}', 'bartag', '%{tag2}']
        ]
      }
    end

    let(:event) { LogStash::Event.new('val1' => 123,
                                      'val2' => 456,
                                      'tag1' => 'gatoof',
                                      'tag2' => 'rabgat') }

    it 'sends the correct opentsdb format' do
      expect(subject.socket.pop).to match(/^put metric_2 \d+ 456 bartag=rabgat\n/)
      expect(subject.socket.pop).to match(/^put metric_1 \d+ 123 footag=gatoof\n/)
    end
  end
end
