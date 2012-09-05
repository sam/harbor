require_relative "helper"

class FormTest < MiniTest::Unit::TestCase

  class SimplestForm < Harbor::Form ; end

  class TestForm < Harbor::Form
    string :first_name
    integer :age, min_value: 18
  end

  class BooleanForm < Harbor::Form
    integer :score
    boolean :awesome
  end

  def setup
    @request = Harbor::Test::Request.new
    @response = Harbor::Response.new(@request)
  end

  def test_sanity
    form = Harbor::Form.new(@request, @response)
    refute_nil form
    tf = SimplestForm.new(@request, @response)
    refute_nil tf
  end

  def test_form_with_attributes
    @request.params[:memo] = "A memo."
    @request.params[:first_name] = "James"
    @request.params[:age] = 21
    tf = TestForm.new(@request, @response)
    assert tf.valid?

    @request.params[:age] = 9
    tf = TestForm.new(@request, @response)
    refute tf.valid?

    @request.params[:age] = 21
    @request.params[:irhackingu] = ';DROP TABLE users;--'
    tf = TestForm.new(@request, @response)
    assert_nil tf[:irhackingu]
    assert tf.valid?
  end

  def test_required_boolean_not_in_request
    @request[:score] = '9000'
    # @request[:awesome] = false
    bf = BooleanForm.new(@request, @response)
    assert bf.valid?

    ['false', 'true', false, true, nil].each do |bool|
      @request[:awesome] = bool
      bf = BooleanForm.new(@request, @response)
      assert bf.valid?
    end

  end

end
