require 'test_helper'

class PopsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @pop = pops(:one)
  end

  test "should get index" do
    get pops_url
    assert_response :success
  end

  test "should get new" do
    get new_pop_url
    assert_response :success
  end

  test "should create pop" do
    assert_difference('Pop.count') do
      post pops_url, params: { pop: {  } }
    end

    assert_redirected_to pop_url(Pop.last)
  end

  test "should show pop" do
    get pop_url(@pop)
    assert_response :success
  end

  test "should get edit" do
    get edit_pop_url(@pop)
    assert_response :success
  end

  test "should update pop" do
    patch pop_url(@pop), params: { pop: {  } }
    assert_redirected_to pop_url(@pop)
  end

  test "should destroy pop" do
    assert_difference('Pop.count', -1) do
      delete pop_url(@pop)
    end

    assert_redirected_to pops_url
  end
end
