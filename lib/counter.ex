defmodule Counter do
  @moduledoc """
  Counter module generates a value, unique for the pair id, timestamp received
  """

  @doc """
  	Receives a list of options, as per convention

  	Returns an atom and pid

  	This function waits for a millisecond before creating an agent, this is
  	to ensure that in case of system failure when the counters are lost, there won't
  	be the same counters generated for the same milisecond.
  """
  def start_link(_opts) do
  	Process.sleep(1)
  	Agent.start_link(fn -> %{} end)
  end


  @doc """
	Receives a pid, id and timestamp

	Returns a value unique for the pair id and timestamp

	Uses a map of the format id => [timestamp, counter]
  """
  def get_counter(bucket, id, current_timestamp) do
  	#check if the id is valid
  	cond do
  		id < 0 or id > 1023 -> 
  			nil
  		id >= 0 and id <= 1023 ->
  			# get the values stored in the map for id key
		  	values = Agent.get(bucket, &Map.get(&1, id))
		  	cond do
		  		# if there are no values stored for id key, initialize the map for id with timestamp and counter 0
		  		values == nil ->
		  			update_bucket(bucket, id, current_timestamp, 0)
		  		
		  		# if there are values stored for id key, split them in head and tail
		  		values != nil ->
		  			# list = Agent.get(bucket, &Map.get(&1, id))
		  			stored_timestamp = List.first(values)
		  			counter = List.last(values)

		  			cond do
		  				# if the timestamp received is the same as the timestamp stored, increase counter
		  				current_timestamp == stored_timestamp ->
		   					update_bucket(bucket, id, stored_timestamp, counter + 1)
		  				# if the timestamp received is different than the timestamp stored, reinitialize counter
		  				current_timestamp != stored_timestamp ->
		  					update_bucket(bucket, id, current_timestamp, 0)
		  			end
		  	end
	end
  end


  @doc """
	Receives a pid, id, timestamp and counter

	Returns the counter after the map value is updated for id key
  """
  defp update_bucket(bucket, id, timestamp, counter) do
  	# for id key, the value is updated with a list of two elements: timestamp and counter
  	Agent.update(bucket, &Map.put(&1, id, [timestamp, counter]))
  	values = Agent.get(bucket, &Map.get(&1, id))
  	List.last(values)
  end
end