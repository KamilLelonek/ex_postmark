defmodule ExPostmark.Adapters.Local do
  @moduledoc ~S"""
  An adapter that stores the email locally, using the specified storage driver.
  This is especially useful in development to avoid sending real emails.
  You can read the emails you have sent using functions in the
  [ExPostmark.Adapters.Local.Storage](ExPostmark.Adapters.Local.Storage.html).

  ## Example
      # config/config.exs
      config :sample, Sample.Mailer,
        adapter: ExPostmark.Adapters.Local

      # lib/sample/mailer.ex
      defmodule Sample.Mailer do
        use ExPostmark.Mailer, otp_app: :sample
      end
  """
  use ExPostmark.Adapter

  def deliver(%ExPostmark.Email{} = email, _config) do
    %ExPostmark.Email{headers: %{"Message-ID" => id}} = ExPostmark.Adapters.Local.Storage.push(email)

    {:ok, %{id: id}}
  end
end
