defmodule PoolyV3.PoolServer do
  @moduledoc """
  Pool level logic
  """
  use GenServer

  require Logger

  defmodule State do
    defstruct pool_sup: nil,
              worker_sup: nil,
              size: nil,
              worker_mod: nil,
              workers: nil,
              monitors: nil,
              name: nil
  end

  # API

  def start_link([pool_sup, pool_config]) do
    GenServer.start_link(__MODULE__, [pool_sup, pool_config], name: name(pool_config[:name]))
  end

  def checkout(pool_name) do
    GenServer.call(name(pool_name), :checkout)
  end

  def checkin(pool_name, worker_pid) do
    GenServer.cast(name(pool_name), {:checkin, worker_pid})
  end

  def status(pool_name) do
    GenServer.call(name(pool_name), :status)
  end

  # Callbacks

  def init([pool_sup, pool_config] = _init_args) when is_pid(pool_sup) do
    Process.flag(:trap_exit, true)
    monitors = :ets.new(:monitors, [:private])
    init(pool_config, %State{pool_sup: pool_sup, monitors: monitors})
  end

  def init([{:name, name} | rest], state) do
    init(rest, %{state | name: name})
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

  def handle_info(
        :start_worker_supervisor,
        state = %{
          size: size,
          worker_mod: worker_mod,
          pool_sup: pool_sup,
          name: name
        }
      ) do
    child_spec = %{
      id: "#{name}WorkerSupervisor" |> String.to_atom(),
      start: {PoolyV3.WorkerSupervisor, :start_link, [self(), []]},
      restart: :temporary
    }

    {:ok, worker_sup} = Supervisor.start_child(pool_sup, child_spec)

    workers = prepopulate(size, worker_mod, worker_sup)

    {:noreply, %{state | worker_sup: worker_sup, workers: workers}}
  end

  def handle_info({:DOWN, ref, _, _, _}, state = %{monitors: monitors, workers: workers}) do
    case :ets.match(monitors, {:"$1", ref}) do
      [[pid]] ->
        true = :ets.delete(monitors, pid)
        new_state = %{state | workers: [pid | workers]}
        {:noreply, new_state}

      [[]] ->
        {:noreply, state}
    end
  end

  def handle_info(
        {:EXIT, pid, _reason},
        state = %{
          monitors: monitors,
          workers: workers,
          worker_mod: worker_mod,
          worker_sup: worker_sup
        }
      ) do
    case :ets.lookup(monitors, pid) do
      [{pid, ref}] ->
        true = Process.demonitor(ref)
        true = :ets.delete(monitors, pid)
        new_state = %{state | workers: [new_worker(worker_mod, worker_sup) | workers]}
        {:noreply, new_state}

      _ ->
        {:noreply, state}
    end
  end

  def terminate(_reason, _state) do
    :ok
  end

  # Private functions

  defp name(pool_name) do
    :"#{pool_name}Server"
  end

  defp prepopulate(size, worker_mod, worker_sup) do
    Logger.warn(inspect(worker_sup))

    prepopulate(size, worker_mod, worker_sup, [])
  end

  defp prepopulate(size, _worker_mod, _worker_sup, workers) when size < 1 do
    workers
  end

  defp prepopulate(size, worker_mod, worker_sup, workers) do
    prepopulate(size - 1, worker_mod, worker_sup, [new_worker(worker_mod, worker_sup) | workers])
  end

  defp new_worker(worker_mod, worker_sup) do
    {:ok, worker} = DynamicSupervisor.start_child(worker_sup, worker_mod)

    worker
  end
end
