defmodule Sender do
  @moduledoc """
  Using Task start.
  """

  def send_email(email) do
    Process.sleep(3000)
    IO.puts("Email to #{email} sent")
    {:ok, "email sent"}
  end

  def notify_all(emails) do
    emails
    |> Enum.each(fn email ->
      Task.start(fn ->
        send_email(email)
      end)
    end)
  end
end
