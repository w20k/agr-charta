$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'byebug'
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
