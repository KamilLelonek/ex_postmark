defmodule ExPostmark.MailerTest do
  use ExUnit.Case, async: true

  defmodule FakeAdapter do
    use ExPostmark.Adapter,
      required_config: [:api_key]

    def deliver(email, _config), do: {:ok, email}
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

      def deliver(email, _config), do: {:ok, email}
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

  test "should interpret configuration at runtime", %{email: email} do
    defmodule ReplaceConfigAdapter do
      use ExPostmark.Adapter, required_config: [
                                :pid,
                                :replace_without_default_empty,
                                :replace_with_default_empty,
                                :replace_without_default_not_empty,
                                :replace_with_default_not_empty
                              ]

      def deliver(email, config) do
        send(
          config[:pid],
          %{
            replace_without_default_empty:     config[:replace_without_default_empty],
            replace_with_default_empty:        config[:replace_with_default_empty],
            replace_without_default_not_empty: config[:replace_without_default_not_empty],
            replace_with_default_not_empty:    config[:replace_with_default_not_empty]
          }
        )
        {:ok, email}
      end
    end

    System.put_env("NOT_EMPTY_ENV_VAR", "value")

    Application.put_env(
      :ex_postmark,                      ExPostmark.MailerTest.ReplaceConfigMailer,
      adapter:                           ReplaceConfigAdapter,
      pid:                               self(),
      replace_without_default_empty:     {:system, "EMPTY_ENV_VAR"},
      replace_with_default_empty:        {:system, "EMPTY_ENV_VAR", "default"},
      replace_without_default_not_empty: {:system, "NOT_EMPTY_ENV_VAR"},
      replace_with_default_not_empty:    {:system, "NOT_EMPTY_ENV_VAR", "default"},
    )

    defmodule ReplaceConfigMailer do
      use ExPostmark.Mailer, otp_app: :ex_postmark
    end

    ReplaceConfigMailer.deliver(email)

    assert_receive %{
      replace_without_default_empty:     nil,
      replace_with_default_empty:        "default",
      replace_without_default_not_empty: "value",
      replace_with_default_not_empty:    "value"
    }
  end
end
