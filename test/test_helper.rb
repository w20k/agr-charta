# frozen_string_literal: true

require_relative '../lib/charta'

require 'charta'
require 'pathname'
require 'minitest/autorun'

module Charta
  class Test < Minitest::Test
    def fixture_files_path
      Pathname.new(__FILE__).dirname.join('fixtures')
    end
  end
end
