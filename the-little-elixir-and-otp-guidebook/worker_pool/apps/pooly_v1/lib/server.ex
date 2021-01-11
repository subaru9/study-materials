defmodule PoolyV1.Server do
  @moduledoc """
  Handles most of the logic
  """
  use GenServer

  require Logger

  defmodule State do
    defstruct sup: nil, size: nil, worker_mod: nil, workers: nil, monitors: nil
  end

  # API

  def start_link(init_args) do
    GenServer.start_link(__MODULE__, init_args, name: __MODULE__)
  end

  def checkout() do
    GenServer.call(__MODULE__, :checkout)
  end

  def checkin(worker_pid) do
    GenServer.cast(__MODULE__, {:checkin, worker_pid})
  end

  def status do
    GenServer.call(__MODULE__, :status)
  end

  # Callbacks

  def init([sup, pool_config] = _init_args) when is_pid(sup) do
    monitors = :ets.new(:monitors, [:private])
    init(pool_config, %State{sup: sup, monitors: monitors})
  end

  def init([{:worker_mod, worker_mod} | rest], state) do
    init(rest, %{state | worker_mod: worker_mod})
  end

  def init([{:size, size} | rest], state) do
    init(rest, %{state | size: size})
  end

  def init([_ | rest], state) do
    init(rest, state)
  end

  def init([], state) do
    send(self(), :start_worker_supervisor)
    {:ok, state}
  end

  def handle_info(
        :start_worker_supervisor,
        state = %{
          size: size,
          worker_mod: worker_mod
        }
      ) do
    {:ok, _worker_sup} = PoolyV1.WorkerSupervisor.start_link([])

    prepopulate(size, worker_mod)

    {:noreply, state}
  end

  # Private functions

  defp prepopulate(size, worker_mod) do
    prepopulate(size, worker_mod, [])
  end

  defp prepopulate(size, _worker_mod, workers) when size < 1 do
    workers
  end

  defp prepopulate(size, worker_mod, workers) do
    prepopulate(size - 1, worker_mod, [new_worker(worker_mod) | workers])
  end

  defp new_worker(worker_mod) do
    {:ok, worker} = PoolyV1.WorkerSupervisor.start_child(worker_mod)
    worker
  end

  def handle_call(:status, _from, %{workers: workers, monitors: monitors} = state) do
    {:reply, {length(workers), :ets.info(monitors, :size)}, state}
  end

  def handle_call(:checkout, {from_pid, _red}, %{workers: workers, monitors: monitors} = state) do
    case workers do
      [worker | rest] ->
        ref = Process.monitor(from_pid)
        true = :ets.insert(monitors, {worker, ref})
        {:reply, worker, %{state | workers: rest}}

      [] ->
        {:reply, :noproc, state}
    end
  end

  def handle_call({:checkin, worker}, %{workers: workers, monitors: monitors} = state) do
    case :ets.lookup(monitors, worker) do
      [{pid, ref}] ->
        true = Process.demonitor(ref)
        true = :ets.delete(monitors, pid)
        {:noreply, worker, %{state | workers: [pid | workers]}}

      [] ->
        {:noreply, state}
    end
  end
end
