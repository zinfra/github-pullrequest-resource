# frozen_string_literal: true

module Filters
  class WIP
    def initialize(pull_requests:, input: Input.instance)
      @pull_requests = pull_requests
      @input = input
    end

    def pull_requests
      if @input.source.no_wip
        @pull_requests.delete_if { |pr| pr.title =~ /\[wip\]/i }
      end

      @pull_requests
    end
  end
end
