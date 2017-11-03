require 'test_helper'

class LatenciesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @latency = latencies(:one)
  end

  test "should get index" do
    get latencies_url
    assert_response :success
  end

  test "should get new" do
    get new_latency_url
    assert_response :success
  end

  test "should create latency" do
    assert_difference('Latency.count') do
      post latencies_url, params: { latency: {  } }
    end

    assert_redirected_to latency_url(Latency.last)
  end

  test "should show latency" do
    get latency_url(@latency)
    assert_response :success
  end

  test "should get edit" do
    get edit_latency_url(@latency)
    assert_response :success
  end

  test "should update latency" do
    patch latency_url(@latency), params: { latency: {  } }
    assert_redirected_to latency_url(@latency)
  end

  test "should destroy latency" do
    assert_difference('Latency.count', -1) do
      delete latency_url(@latency)
    end

    assert_redirected_to latencies_url
  end
end
