defmodule GlobalIdTest do
  use ExUnit.Case
  doctest GlobalId

  test "assert id example" do
    assert GlobalId.generate_id(256, 1234567890, 311) == 2305843641312453943
  end

end
