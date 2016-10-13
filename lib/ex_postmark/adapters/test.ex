defmodule ExPostmark.Adapters.Test do
  @moduledoc ~S"""
  An adapter that sends emails as messages to the current process.
  This is meant to be used during tests.

  ## Example
      # config/test.exs
      config :sample, Sample.Mailer,
        adapter: ExPostmark.Adapters.Test

      # lib/sample/mailer.ex
      defmodule Sample.Mailer do
        use ExPostmark.Mailer, otp_app: :sample
      end
  """
  use ExPostmark.Adapter

  def deliver(email) do
    send(self(), {:email, email})

    {:ok, %{}}
  end
end
