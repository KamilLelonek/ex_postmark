defmodule ExPostmark.Adapters.PostmarkTest do
  use ExUnit.Case, async: true

  alias ExPostmark.Adapters.{Postmark, FakeRestAdapter}
  alias ExPostmark.Email

  @config [server_api_key: "abc123"]
  @email  Email.new(
    from:           {"From", "from@example.com"},
    to:             "to@example.com",
    cc:             ["cc1@example.com", {"CC2", "cc1@example.com"}],
    bcc:            "bcc@example.com",
    reply_to:       "reply_to@example.com",
    headers:        %{"X-Accept-Language" => "pl"},
    template_id:    1,
    template_model: %{name: "name", team: "team"}
  )

  describe "validate_config/1" do
    test "should raise with missing Server API key" do
      assert_raise(
        ArgumentError,
        "expected [:server_api_key] to be set, got: []",
        fn ->
          Postmark.validate_config([])
        end
      )
    end

    test "should succesfuly validate a correct config" do
      assert :ok = Postmark.validate_config(@config)
    end
  end

  test "should build a correct body from an Email" do
    assert Postmark.body(@email) == %{
      "Bcc"           => "bcc@example.com",
      "Cc"            => "cc1@example.com,\"CC2\" <cc1@example.com>",
      "From"          => "\"From\" <from@example.com>",
      "ReplyTo"       => "reply_to@example.com",
      "TemplateId"    => 1,
      "TemplateModel" => %{name: "name", team: "team"},
      "To"            => "to@example.com"
    }
  end

  describe "deliver/2" do
    Application.put_env(:ex_postmark, :rest_adapter, FakeRestAdapter)

    test "should handle unknown response code" do
      FakeRestAdapter.set_response_code(404)
      assert {:error, {404, _body}} = Postmark.deliver(@email, [])
    end

    test "should handle any error" do
      FakeRestAdapter.set_response_code(:error)
      assert {:error, "Request error!"} = Postmark.deliver(@email, [])
    end

    test "should send a valid email" do
      FakeRestAdapter.set_response_code(:ok)
      assert {:ok, %{id: _id}} = Postmark.deliver(@email, [])
    end
  end
end
