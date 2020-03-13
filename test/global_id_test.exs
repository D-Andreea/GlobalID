defmodule GlobalIdTest do
  use ExUnit.Case
  doctest GlobalId

  test "assert id example" do
    assert GlobalId.generate_id(256, 1234567890, 311) == 2305843641312453943
  end


  test "example" do
  	{:ok, bucket} = Counter.start_link([])
  	
  	call1 = Task.async(fn -> GlobalId.get_id(bucket) end)
  	call2 = Task.async(fn -> GlobalId.get_id(bucket) end)

  	id1 = Task.await(call1)
  	id2 = Task.await(call2)

  	assert id1 != id2
  end

end
