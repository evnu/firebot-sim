defmodule Replay.Inserter do
  @moduledoc """
  Asynchronous telemetry inserter.
  """
  use GenServer

  @insert_interval 1000 # ms

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @doc """
  Add an `insert` for asynchronous insertion.
  """
  def insert_async(changeset) do
    GenServer.call(__MODULE__, {:add_insert, changeset})
  end

  @impl true
  def init(_args) do
    :timer.send_interval(@insert_interval, :write_batch)
    {:ok, %{}}
  end

  @impl true
  def handle_call({:add_insert, changeset}, _, insertions) do
    {:reply, :ok, [changeset | insertions]}
  end

  @impl true
  def handle_info(:write_batch, insertions) do
    for changeset <- insertions do
      Replay.Repo.insert!(changeset)
    end
    {:noreply, []}
  end
end
