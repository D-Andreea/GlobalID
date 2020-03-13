defmodule GlobalId do
  @moduledoc """
  GlobalId module contains an implementation of a guaranteed globally unique id system.     
  """

  #
  # To generate a guaranteed globally unique id, 3 components were used:
  # 1. node id: ensures unicity of ids between nodes (max value 1023 => 10 bits)
  # 2. timestamp: ensures unicity of ids in case of a node or system failure (44 bits reserved)
  # 3. counter: ensures unicity between ids generated concurrent in the same millisecond, at the same node (max value 512 => 9 bits)
  # 
  #
  # This method is guaranteed globally unique because of it's timestamp and random number combination. 
  # We assume that there are 100,000 requests per second or 100 requests per milisecond. 
  # For each milisecond there can be maximum 512 unique random numbers generated, which covers the need.
  # 


  @doc """
    Converts a bitstring to its integer equivalent
  """
  def get_int64(<<num::signed-integer-size(64)>>) do
    num
  end


  @doc """
    Generates a timestamp in miliseconds, by substracting the timestamp for 2020-01-01 from the system time
  """
  def generate_timestamp() do
      use Timex

      current_timestamp = timestamp()

      epoch_start = "2020-01-01"
      epoch_start_date = Timex.parse!(epoch_start, "%Y-%m-%d", :strftime)
      epoch_timestamp = DateTime.to_unix(Timex.to_datetime(epoch_start_date), :millisecond)

      current_timestamp - epoch_timestamp
  end


  @doc """
    Receives the components needed for an id and returns the id on 64 bits
    The first bit is always 0 so the id is positive, the next 10 bits hold
    the node id, the next 44 bits are reserved for the timestamp and last 9 bits
    represent a random number
  """
  def generate_id(node_id, timestamp, random_number) do
    unique_id = <<0::1, node_id::10, timestamp::44, random_number::9>>
    get_int64(unique_id)
  end


  @doc """
  Please implement the following function.
  64 bit non negative integer output   
  """
  @spec get_id(pid()) :: non_neg_integer
  def get_id(bucket) do # this function requires the pid for Counter module
      # getting the node id
      node_id = node_id()

      # getting the timestamp
      timestamp = generate_timestamp()
      
      # calling the Counter API to get the counter
      counter = Counter.get_counter(bucket, node_id, timestamp)

      cond do
        counter >= 512 ->
          # if there are more than 512 requests per milisecond for an id, wait a milisecond before generating a new counter
          Process.sleep(1)
          counter = Counter.get_counter(bucket, node_id, timestamp)

          # getting the id formed from node id, timestamp and the random number generated above
          generate_id(node_id, timestamp, counter)
        counter < 512 ->
          # getting the id formed from node id, timestamp and the random number generated above
          generate_id(node_id, timestamp, counter)
      end      
  end


  #
  # You are given the following helper functions
  # Presume they are implemented - there is no need to implement them. 
  #

  
  @doc """
  Returns your node id as an integer.
  It will be greater than or equal to 0 and less than or equal to 1024.
  It is guaranteed to be globally unique. 
  """
  @spec node_id() :: non_neg_integer
  def node_id() do
    1023
  end


  @doc """
  Returns timestamp since the epoch in milliseconds. 
  """
  @spec timestamp() :: non_neg_integer
  def timestamp() do
    {mega, seconds, ms} = :os.timestamp()
    (mega*1000000 + seconds)*1000 + :erlang.round(ms/1000) 
  end
end