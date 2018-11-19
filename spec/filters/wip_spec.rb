# frozen_string_literal: true

require_relative '../../assets/lib/filters/wip'
require_relative '../../assets/lib/pull_request'
require_relative '../../assets/lib/input'
require 'webmock/rspec'

describe Filters::WIP do
  let(:ignore_pr) do
    PullRequest.new(pr: { 'number' => 1,
                          'base' => { 'repo' => { 'full_name' => 'user/repo' } } })
  end

  let(:pr) do
    PullRequest.new(pr: { 'number' => 2,
                          'base' => { 'repo' => { 'full_name' => 'user/repo' } } })
  end

  let(:pull_requests) { [ignore_pr, pr] }

  def stub_json(uri, body)
    stub_request(:get, uri)
      .to_return(headers: { 'Content-Type' => 'application/json' }, body: body.to_json)
  end

  context 'when no_wip is disabled' do
    it 'does not filter' do
      payload = { 'source' => { 'repo' => 'user/repo' } }
      filter = described_class.new(pull_requests: pull_requests, input: Input.instance(payload: payload))

      expect(filter.pull_requests).to eq pull_requests
    end
  end

  context 'when no_wip is enabled' do
    before do
      stub_json(%r{https://api.github.com/repos/user/repo/pulls/1}, 'title' => '[WIP] Do stuff')
      stub_json(%r{https://api.github.com/repos/user/repo/pulls/2}, 'title' => 'Do other stuff')
    end

    it 'only returns PRs without [WIP]' do
      payload = { 'source' => { 'repo' => 'user/repo', 'no_wip' => true } }
      filter = described_class.new(pull_requests: pull_requests, input: Input.instance(payload: payload))

      expect(filter.pull_requests).to eq [pr]
    end
  end
end
