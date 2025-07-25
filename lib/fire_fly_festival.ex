defmodule FireFlyFestival do
# Declaring constants below which
# These can be used to configure the required parameters
# asked in the assignment
  @firefly_count 10 #10 fireflies
  @on_time 500 # 500ms = 0.5sec
  @off_time 2000 # 2000ms = 2sec
  @update_time 100 # 100ms = 0.1sec internal update clock
  @adjustment_time 1000 #1000ms = 1sec max adjustment time
  @output_frequency 30 # 30 times per second
  @clear_screen IO.ANSI.home() <> IO.ANSI.clear() # Helps to clear screen for each line print
  @on_display_char "B" # Display this when on state
  @off_display_char " " # Display this when off state

  def start do
    IO.puts("Starting the Firefly Festival.")

    # To generate a random seed 
    # for different behavior on each run
    :rand.seed(:exsplus, :os.timestamp())

    # Enumerating the range to spawn required firefly processes
    firefly_pids = Enum.map(0..(@firefly_count - 1), fn fly_num -> 
      start_delay = :rand.uniform(@off_time) # Picking random delay 
      spawn_link(fn -> firefly(fly_num, :off, start_delay) end) # Spawning fireflies
    end)

    # Traversing the PIDs of the fireflies
    # To calculate their right neighbour and set it
    Enum.each(Enum.with_index(firefly_pids), fn {pid, index} -> 
      right_fly = if (index == @firefly_count - 1), do: 0, else: index + 1
      right_pid = Enum.at(firefly_pids, right_fly)
      send(pid, {:init, right_pid, self()})
    end)

    # Start displaying the fireflies behavior
    display_festival(%{}, @firefly_count)
  end

  # When a firefly gets the init message
  # we fill its details and start it's action
  defp firefly(fly_num, state, start_delay) do
    receive do
      {:init, right_pid, parent_pid} -> firefly_action(fly_num, state, start_delay, right_pid, parent_pid)
    end
  end

  # This is called after firefly action is initialized
  # This will keep looping and update the state 
  # It sends ticks and determines the state of the fly
  # whether it has to tick or blink
  defp firefly_action(fly_num, state, time_left, right_pid, parent_pid) do
    Process.send_after(self(), :tick, @update_time) # Each tick (10 per second default)
    send(parent_pid, {:state, fly_num, state}) # Sending our state to parent for printing

    # Receives actions and performs actions continuously
    receive do
      :tick -> # A tick received
        current_time_left = time_left - @update_time # Hence we reduce the time left for a state change

        cond do
        # If state was off and timer is finished we set state to on
          state == :off and current_time_left <= 0 ->
            send(right_pid, :blink) # We also signal right firefly to blink earlier
            firefly_action(fly_num, :on, @on_time, right_pid, parent_pid)
        # If state was on and timer is finished we set state to off
          state == :on and current_time_left <= 0 -> 
            firefly_action(fly_num, :off, @off_time, right_pid, parent_pid)
        #Fallback for other cases - no state update only time updated
          true ->
            firefly_action(fly_num, state, current_time_left, right_pid, parent_pid)
        end

      :blink -> # A blink recieved from our left firefly
        # Reducing only by a maximum of 1 sec (@adjustment_time)
        # Max with 0, as time could be negative
        current_time_left = 
          if state == :off do
            max(time_left - @adjustment_time, 0)
          else
            time_left
          end

        firefly_action(fly_num, state, current_time_left, right_pid, parent_pid)
    end
  end

  # Display handler that receives state updates
  defp display_festival(states, fly_count) do
    receive do
      {:state, fly_num, state} -> # Received a state from Firefly #fly_num
        updated_states = Map.put(states, fly_num, state) # Updating the state
        if map_size(updated_states) == fly_count do
          # If all states received then display the states
          display(updated_states, fly_count)
          :timer.sleep(div(1000, @output_frequency)) # Wait for next frame based on output frequency param
          display_festival(%{}, fly_count) # Reset the states
        else
          display_festival(updated_states, fly_count) # Keep waiting if not all flies updated
        end
    end
  end

  defp display(states, fly_count) do
    IO.write(@clear_screen) #Clearing screen for displayin next set of states
    to_display_line = # Iterate over all the states to get the state to display for each fly (on or off)
      0..(fly_count - 1)
      |> Enum.map(fn fly_num -> if states[fly_num] == :on, do: @on_display_char, else: @off_display_char end) 
      |> Enum.join()
    IO.puts(to_display_line) # Display the line finally
  end
end

FireFlyFestival.start()