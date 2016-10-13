defmodule ExPostmark.Adapters.TestTest do
  use ExUnit.Case, async: true

  Application.put_env(
    :ex_postmark, ExPostmark.Adapters.TestTest.FakeMailer,
    adapter:      ExPostmark.Adapters.Test
  )

  defmodule FakeMailer do
    use ExPostmark.Mailer, otp_app: :ex_postmark
  end

  test "should send an Email using Test adapter" do
    email = ExPostmark.Email.new(
      from:           "from@example.com",
      to:             "to@example.com",
      template_id:    1,
      template_model: %{name: "name", team: "team"}
    )

    FakeMailer.deliver(email)

    assert_received {:email, ^email}
  end
end
