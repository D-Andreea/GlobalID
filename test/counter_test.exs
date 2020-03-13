defmodule CounterTest do
  use ExUnit.Case, async: true

  setup do
  	{:ok, bucket} = Counter.start_link([])

  	timestamp = 123456789

  	%{bucket: bucket, timestamp: timestamp}
  end

  test "counter by id, same milisecond", %{bucket: bucket, timestamp: timestamp}
 do
  	assert Counter.get_counter(bucket, 0, timestamp) == 0
  	assert Counter.get_counter(bucket, 0, timestamp) == 1
  	assert Counter.get_counter(bucket, 0, timestamp) == 2

  	assert Counter.get_counter(bucket, 1023, timestamp) == 0
  	assert Counter.get_counter(bucket, 1023, timestamp) == 1
  end


  test "counter by id, different miliseconds", %{bucket: bucket, timestamp: timestamp} do
  	assert Counter.get_counter(bucket, 123, timestamp) == 0

  	timestamp = timestamp + 1

  	assert Counter.get_counter(bucket, 123, timestamp) == 0
  end


  test "negative id", %{bucket: bucket, timestamp: timestamp} do
  	assert Counter.get_counter(bucket, -1, timestamp) == nil
  end


  test "bigger than 1023 id", %{bucket: bucket, timestamp: timestamp} do
  	{:ok, bucket} = Counter.start_link([])

  	assert Counter.get_counter(bucket, 1024, timestamp) == nil
  end


  test "check milisecond at startup" do
  	before_startup = :os.system_time(:millisecond)
	
	{:ok, _bucket} = Counter.start_link([])
 	
 	after_startup = :os.system_time(:millisecond)

    assert after_startup - before_startup > 1
  end
end