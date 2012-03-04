require "minitest/autorun"
require_relative '../../lib/harbor/router/tree'
require_relative '../../lib/harbor/router/route_node'

module Router
  class TreeTest < MiniTest::Unit::TestCase
    def setup
      @tree = Harbor::Router::Tree.new
    end

    def test_creates_home_node_if_tokens_are_empty
      @tree.insert([], :home)
      assert_equal :home, @tree.home.action
    end

    def test_replaces_home_node_with_new_node
      @tree.insert([], :home).insert([], :new_home)
      assert_equal :new_home, @tree.home.action
    end

    def test_creates_root_node_for_single_token
      @tree.insert(['posts'], :action)
      assert_equal :action, @tree.root.action
      assert_equal 'posts', @tree.root.fragment
    end

    def test_delegates_insertion_to_root_node
      mock = MiniTest::Mock.new
      mock.expect :insert, nil, [:action, ['posts']]
      @tree.instance_variable_set(:@root, mock)

      @tree.insert(['posts'], :action)

      assert mock.verify
    end

    def test_delegates_search_to_root_node
      mock = MiniTest::Mock.new
      mock.expect :search, nil, [['posts']]
      @tree.instance_variable_set(:@root, mock)

      @tree.search(['posts'])

      assert mock.verify
    end

    def test_matches_home_route_if_registered
      @tree.insert([], :home)
      assert_equal :home, @tree.search([]).action
    end
  end
end