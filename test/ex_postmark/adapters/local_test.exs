defmodule ExPostmark.Adapters.LocalTest do
  use ExUnit.Case

  alias ExPostmark.Adapters.Local.Storage

  Application.put_env(
    :ex_postmark, ExPostmark.Adapters.LocalTest.FakeMailer,
    adapter:      ExPostmark.Adapters.Local
  )

  defmodule FakeMailer do
    use ExPostmark.Mailer, otp_app: :ex_postmark
  end

  setup do
    Storage.start_link()
    Storage.delete_all()
    :ok
  end

  test "should send an Email using Test adapter" do
    email = ExPostmark.Email.new(
      from:           "from@example.com",
      to:             "to@example.com",
      template_id:    1,
      template_model: %{name: "name", team: "team"}
    )

    assert {:ok, %{id: id}} = FakeMailer.deliver(email)
    assert Storage.get(id) == %ExPostmark.Email{
      bcc:            [],
      cc:             [],
      from:           {"", "from@example.com"},
      headers:        %{"Message-ID" => id},
      reply_to:       nil,
      template_id:    1,
      template_model: %{name: "name", team: "team"},
      to:             [{"", "to@example.com"}]
    }
  end
end
