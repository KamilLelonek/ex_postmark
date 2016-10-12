defmodule ExPostmark.MailerTest do
  use ExUnit.Case, async: true

  defmodule FakeAdapter do
    use ExPostmark.Adapter,
      required_config: [:api_key]

    def deliver(email), do: {:ok, email}
  end

  Application.put_env(
    :ex_postmark, ExPostmark.MailerTest.FakeMailer,
    api_key:      "api-key",
    adapter:      FakeAdapter
  )

  defmodule FakeMailer do
    use ExPostmark.Mailer, otp_app: :ex_postmark
  end

  setup_all do
    email = ExPostmark.Email.new(
      from:           "from@example.com",
      to:             "to@example.com",
      template_id:    1,
      template_model: %{name: "name", team: "team"}
    )

    {:ok, email: email}
  end

  test "should send an Email", %{email: email} do
    assert FakeMailer.deliver(email) == {:ok, %ExPostmark.Email{
      bcc:            [],
      cc:             [],
      from:           {"", "from@example.com"},
      headers:        %{},
      reply_to:       nil,
      template_id:    1,
      template_model: %{name: "name", team: "team"},
      to:             [{"", "to@example.com"}]
    }}
  end

  test "should raise if no adapter is specified" do
    assert_raise ArgumentError, fn ->
      defmodule NoAdapterMailer do
        use ExPostmark.Mailer, otp_app: :random
      end
    end
  end

  test "should raise if deliver!/2 is called with invalid from", %{email: email} do
    assert_raise ExPostmark.DeliveryError, "delivery error: expected `from` to be set", fn ->
      Map.put(email, :from, nil) |> FakeMailer.deliver!()
    end
    assert_raise ExPostmark.DeliveryError, "delivery error: expected `from` to be set", fn ->
      Map.put(email, :from, {"Name", nil}) |> FakeMailer.deliver!()
    end
    assert_raise ExPostmark.DeliveryError, "delivery error: expected `from` to be set", fn ->
      Map.put(email, :from, {"Name", ""}) |> FakeMailer.deliver!()
    end
  end

  test "should validate adapter config", %{email: email} do
    defmodule NoConfigAdapter do
      use ExPostmark.Adapter, required_config: [:xyz]

      def deliver(email), do: {:ok, email}
    end

    Application.put_env(
      :ex_postmark, ExPostmark.MailerTest.NoConfigMailer,
      adapter:      NoConfigAdapter
    )

    defmodule NoConfigMailer do
      use ExPostmark.Mailer, otp_app: :ex_postmark
    end

    assert_raise ArgumentError, "expected [:xyz] to be set, got: []", fn ->
      NoConfigMailer.deliver(email)
    end
  end
end
