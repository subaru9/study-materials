defmodule PoolyV1.ServerTmp do
  use GenServer
  require Logger

  def init(init_arg) do
    send(self(), :msg)
    {:ok, init_arg}
  end

  def handle_info(:msg, state) do
    Logger.info "Here!"
    {:noreply, state}
  end
end
