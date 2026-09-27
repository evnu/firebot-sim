defmodule Simulator.Grid do
  use GenServer

  alias Simulator.Fire
  alias Simulator.FireStation
  alias Simulator.Reporter

  defmodule State do
    alias Simulator.Fire

    defstruct [:size, fires: %{}]

    @doc """
    Add a fire to the state, if there is no fire yet.
    """
    def add_fire(state = %__MODULE__{}, fire = %Fire{}) do
      if state.fires[fire.coordinates] do
        state
      else
        %{state | fires: Map.put(state.fires, fire.coordinates, fire)}
      end
    end

    @doc """
    Drop a fire from the state.
    """
    def delete_fire(state = %__MODULE__{}, fire = %Fire{}) do
      candidate = state.fires[fire.coordinates]

      if candidate && candidate.ref == fire.ref do
        %{state | fires: Map.delete(state.fires, fire.coordinates)}
      else
        state
      end
    end

    @doc """
    Get the fire at the specified coordinates, or return `nil`.
    """
    def get_fire(state = %__MODULE__{}, coordinates) do
      state.fires[coordinates]
    end

    @doc """
    Determine if a fire is currently still active.
    """
    def fire_active?(state = %__MODULE__{}, fire = %Fire{}) do
      !is_nil(get_fire(state, fire.coordinates))
    end
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @doc """
  Reset the grid to the original state.
  """
  def reset do
    GenServer.call(__MODULE__, :reset)
  end

  @doc """
  Get the size of the grid in x-y-coordinates.
  """
  def size do
    GenServer.call(__MODULE__, :size)
  end

  @doc """
  Get the fire at the specified coordinates, or return `nil`.
  """
  def fire(coordinates) do
    GenServer.call(__MODULE__, {:fire, coordinates})
  end

  @doc """
  Remove the fire.
  """
  def extinguished(fire = %Fire{}) do
    GenServer.call(__MODULE__, {:extinguished, fire})
  end

  @impl true
  def init(size: size = {x, y}) when is_integer(x) and is_integer(y) do
    {:ok, %State{size: size}}
  end

  @impl true
  def handle_call(:reset, _, state) do
    {:reply, :ok, %State{size: state.size}}
  end

  def handle_call(:size, _, state) do
    {:reply, state.size, state}
  end

  def handle_call({:mark_fire, timestamp, [fire = %Fire{}]}, _, state) do
    Reporter.report(timestamp, __MODULE__, "marks fire at #{inspect(fire.coordinates)}")

    events = [
      {fire.burns_until, {__MODULE__, :fire_lost, [fire]}}
    ]

    {:reply, {:events, events}, State.add_fire(state, fire)}
  end

  def handle_call({:fire_lost, timestamp, [fire]}, _, state = %State{}) do
    if State.fire_active?(state, fire) do
      Reporter.report(
        timestamp,
        __MODULE__,
        "marks this as a lost cause #{inspect(fire.coordinates)}"
      )

      events = [
        {timestamp + 1, {FireStation, :recall_from_location, fire.coordinates}}
      ]

      {:reply, {:events, events}, State.delete_fire(state, fire)}
    else
      {:reply, {:events, []}, state}
    end
  end

  def handle_call({:fire, coordinates}, _, state) do
    {:reply, State.get_fire(state, coordinates), state}
  end

  def handle_call({:extinguished, fire}, _, state) do
    {:reply, :ok, State.delete_fire(state, fire)}
  end
end
