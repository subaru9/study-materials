defmodule Sender do
  @moduledoc """
  Lasy input evaluation.
  """

  def send_email("hello@world.com" = email) do
    raise "Couldn't send email to #{email}"
  end

  def send_email(email) do
    Process.sleep(3000)
    IO.puts("Email to #{email} sent")
    {:ok, "email sent"}
  end

  def notify_all(emails) do
    Sender.EmailTaskSupervisor
    |> Task.Supervisor.async_stream_nolink(
      emails,
      &send_email/1
    )
    |> Enum.to_list()
  end
end
