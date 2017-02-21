# ex_postmark

[![Build Status](https://travis-ci.org/KamilLelonek/ex_postmark.svg?branch=master)](https://travis-ci.org/KamilLelonek/ex_postmark)

This is a library inspired by [`swoosh`](https://github.com/swoosh/swoosh) for [Postmark](https://postmarkapp.com/) service to send [template emails](http://developer.postmarkapp.com/developer-api-templates.html#email-with-template).

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `ex_postmark` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:ex_postmark, "~> 1.x.x"}]
    end
    ```

  2. Ensure `ex_postmark` is started before your application:

    ```elixir
    def application do
      [applications: [:ex_postmark]]
    end
    ```

## Usage

You will need to prepare a couple of files to make `ex_postmark` working.

### Config

Here is the way how to prepare specific config files:

**Development**

```elixir
# config/dev.ex

config :your_application, YourApplication.Mailer,
  adapter: ExPostmark.Adapters.Local
```

You can access all sent emails using [convenient `ExPostmark.Adapters.Local.Storage` functions](https://hexdocs.pm/ex_postmark/ExPostmark.Adapters.Local.Storage.html#functions).

**Tests**

```elixir
# config/test.ex

config :your_application, YourApplication.Mailer,
  adapter: ExPostmark.Adapters.Test
```

You can access the recent sent email as:

```elixir
assert_received {:email, email}
```

**Production**

```elixir
# config/prod.ex

config :your_application, YourApplication.Mailer,
  adapter:        ExPostmark.Adapters.Postmark,
  server_api_key: System.get_env("POSTMARK_SERVER_API_KEY")
```

Emails are being sent using regular Postmark platform.

### Mailer

Next, you have to prepare a corresponding mailer:

```elixir
# your_application/mailer.ex

defmodule YourApplication.Mailer do
	use ExPostmark.Mailer, otp_app: :your_application
end
```

Note that `otp_app` represents the configured name.

### Creating an email

Firstly, you have to prepare an email. You can do that in two ways:

**1. Using `new/1` constructor**

```elixir
Email.new(
  from:           {"From", "from@example.com"},
  to:             "to@example.com",
  cc:             ["cc1@example.com", {"CC2", "cc1@example.com"}],
  bcc:            "bcc@example.com",
  reply_to:       "reply_to@example.com",
  headers:        %{"X-Accept-Language" => "pl"},
  template_id:    1,
  template_model: %{name: "name", team: "team"}
)
```

**2. Using builder functions**

```elixir
email = Email.new()
      |> Email.to("foo.bar@example.com")
      |> Email.cc("foo.bar@example.com")
      |> Email.bcc("foo.bar@example.com")
      |> Email.template_id(123)
      |> Email.put_template_model(:name, "Name")
      |> Email.put_template_model(:team, "Team")
```

All functions are available in [docs](https://hexdocs.pm/ex_postmark/ExPostmark.Email.html#functions).

### Sending an email

Once you have an `Email` prepared, you can use your predefined `Mailer` to send it:

```elixir
YourApplication.Mailer.deliver(emai)
```

And that's it, your email should be sent.

**A note about subjects:**

There is a way to set a subject for your email using a template, but it's not done out of the box. You need to make sure to add an additional variable `subject` for your template model and then put it in a place of a `Subject line`.

Here is the final configuration:

![Postmark subject](https://monosnap.com/file/MUem7zVYzB75Oh64FgOUkxGQG98tRZ.png)

Later on, you can use subject in a convenient method like:

```elixir
email = Email.new()
      |> Email.subject("foo.bar@example.com")
      # ...
```

but don't be confused, as it's not a regular way to put a custom subject.

## Tests

To run all tests, execute:

    mix test

Keep in mind that the default command will skip integration tests. To include them, run:

    mix test --include integration

For integration test make sure you have the following vairables exported in your environment:

- `POSTMARK_SERVER_API_KEY ` - Server API token required for authentication from Postmark server credentials
- `POSTMARK_EMAIL_FROM ` - your verified sender signature in Postmark
- `POSTMARK_EMAIL_TO ` - any existing recipient email
- `POSTMARK_TEMPLATE_ID ` - an ID of configured template in Postmark

## Contributing

1. [Fork the repository](https://github.com/KamilLelonek/ex_postmark) and then clone it locally:

  ```bash
  git clone https://github.com/KamilLelonek/ex_postmark
  ```

2. Create a topic branch for your changes:

  ```bash
  git checkout -b fix-mailchimp-pricing-bug
  ```

3. Commit a failing test for the bug:

  ```bash
  git commit -am "Adds a failing test that demonstrates the bug"
  ```

4. Commit a fix that makes the test pass:

  ```bash
  git commit -am "Adds a fix for the bug"
  ```

5. Run the tests:

  ```bash
  mix test
  ```

6. If everything looks good, push to your fork:

  ```bash
  git push origin fix-mailchimp-pricing-bug
  ```

7. [Submit a pull request.](https://help.github.com/articles/creating-a-pull-request)

## Documentation

Documentation is written into the library, you will find it in the source code, accessible from `iex` and of course, it all gets published to [hexdocs](https://hexdocs.pm/ex_postmark).
