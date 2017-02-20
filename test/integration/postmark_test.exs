defmodule ExPostmark.Integration.TestPostmark do
  use ExUnit.Case, async: true

  alias ExPostmark.Email

  @moduletag integration: true

  @postmark_api_key     System.get_env("POSTMARK_SERVER_API_KEY")
  @postmark_template_id System.get_env("POSTMARK_TEMPLATE_ID")
  @postmark_email_from  System.get_env("POSTMARK_EMAIL_FROM")
  @postmark_email_to    System.get_env("POSTMARK_EMAIL_TO")

  @email Email.new(
    subject:        "Hello from TravisCI",
    from:           @postmark_email_from,
    to:             @postmark_email_to,
    template_id:    @postmark_template_id,
    template_model: %{name: "TravisCI", product_name: "ExPostmark"}
  )

  Application.put_env(
    :ex_postmark,   ExPostmark.Integration.TestPostmark.PostmarkMailer,
    server_api_key: @postmark_api_key,
    adapter:        ExPostmark.Adapters.Postmark
  )

  defmodule PostmarkMailer do
    use ExPostmark.Mailer, otp_app: :ex_postmark
  end

  test "should deliver a template email using Postmark service" do
    assert {:ok, %{id: _id}} = PostmarkMailer.deliver(@email)
  end
end
