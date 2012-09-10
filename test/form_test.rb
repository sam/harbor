require_relative "helper"

class FormTest < MiniTest::Unit::TestCase

  class SimplestForm < Harbor::Form ; end

  class TestForm < Harbor::Form
    string :first_name
    integer :age, min_value: 18
  end

  class BooleanForm < Harbor::Form
    integer :score
    boolean :awesome, required: false
  end

  def setup
    @params = {}
  end

  def test_sanity
    form = Harbor::Form.new(@params)
    refute_nil form
    tf = SimplestForm.new(@params)
    refute_nil tf
  end

  def test_form_with_attributes
    @params[:memo] = "A memo."
    @params[:first_name] = "James"
    @params[:age] = 21
    tf = TestForm.new(@params)
    assert tf.valid?

    @params[:age] = 9
    tf = TestForm.new(@params)
    refute tf.valid?

    @params[:age] = 21
    @params[:irhackingu] = ';DROP TABLE users;--'
    tf = TestForm.new(@params)
    assert_nil tf[:irhackingu]
    assert tf.valid?
  end

  def test_boolean_field
    @params[:score] = '9000'
    # @params[:awesome] = false
    bf = BooleanForm.new(@params)
    assert bf.valid?

    ['false', 'true', false, true, nil].each do |bool|
      @params[:awesome] = bool
      bf = BooleanForm.new(@params)
      assert bf.valid?
    end

  end

end
