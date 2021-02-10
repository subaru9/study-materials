defmodule PoolyV3.PoolSupervisor do
  use Supervisor

  ## API

  # Starts a module-based supervisor process with the given module and init_arg.
  def start_link(pool_config) do
    Supervisor.start_link(__MODULE__, pool_config, name: :"#{pool_config[:name]}Supervisor")

    # Supervisor.start_link(__MODULE__, pool_config)
  end

  #############
  # Callbacks #
  #############

  def init(pool_config) do
    children = [
      {PoolyV3.PoolServer, [self(), pool_config]}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end

  def handle_info({:EXIT, worker_sup, reason}, state = %{worker_sup: worker_sup}) do
    {:stop, reason, state}
  end
end
