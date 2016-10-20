defmodule ExPostmark.EmailTest do
  use ExUnit.Case, async: true

  alias ExPostmark.Email

  @name           "Name"
  @from           "from@example.com"
  @to             "to@example.com"
  @cc             "cc@example.com"
  @bcc            "bcc@example.com"
  @reply_to       "reply@example.com"
  @headers        %{"X-Accept-Language" => "pl"}
  @template_id    1
  @template_model %{name: "name", team: "team"}

  describe "new/1" do
    test "should create an empty Email" do
      assert %Email{} = Email.new()
    end

    test "should create an Email with the given fields" do
      email = Email.new(
        from:           @from,
        to:             @to,
        cc:             @cc,
        bcc:            @bcc,
        reply_to:       @reply_to,
        headers:        @headers,
        template_id:    @template_id,
        template_model: @template_model
      )

      assert email.from           == {"", @from}
      assert email.to             == [{"", @to}]
      assert email.cc             == [{"", @cc}]
      assert email.bcc            == [{"", @bcc}]
      assert email.reply_to       == {"", @reply_to}
      assert email.headers        == @headers
      assert email.template_id    == @template_id
      assert email.template_model == @template_model
    end

    test "should raise if arguments contain an unknown field" do
      assert_raise ArgumentError, fn -> Email.new(random: "Random") end
    end
  end

  describe "from/2" do
    test "should put only an email address and an empty name" do
      email = Email.from(Email.new(), @from)

      assert email == %Email{from: {"", @from}}
    end

    test "should put both an email address and a name" do
      from  = {@name, @from}
      email = Email.from(Email.new(), from)

      assert email == %Email{from: from}
    end

    test "should raise if a sender is invalid" do
      assert_raise ArgumentError, fn -> Email.from(Email.new(), nil) end
      assert_raise ArgumentError, fn -> Email.from(Email.new(), "") end
      assert_raise ArgumentError, fn -> Email.from(Email.new(), {nil, nil}) end
      assert_raise ArgumentError, fn -> Email.from(Email.new(), {nil, @from}) end
      assert_raise ArgumentError, fn -> Email.from(Email.new(), {nil, ""}) end
      assert_raise ArgumentError, fn -> Email.from(Email.new(), {"", ""}) end
    end
  end

  describe "to/2" do
    test "should put only an email address and an empty name" do
      email = Email.to(Email.new(), @to)

      assert email == %Email{to: [{"", @to}]}
    end

    test "should put both an email address and a name" do
      to    = {@name, @to}
      email = Email.to(Email.new(), to)

      assert email == %Email{to: [to]}
    end

    test "should put multiple recipients" do
      to    = {@name, @to}
      email = Email.to(Email.new(), [@to, to])

      assert email == %Email{to: [{"", @to}, to]}
    end

    test "should raise if a recipients is invalid" do
      assert_raise ArgumentError, fn -> Email.to(Email.new(), nil) end
      assert_raise ArgumentError, fn -> Email.to(Email.new(), "") end
      assert_raise ArgumentError, fn -> Email.to(Email.new(), {nil, nil}) end
      assert_raise ArgumentError, fn -> Email.to(Email.new(), {nil, @to}) end
      assert_raise ArgumentError, fn -> Email.to(Email.new(), {nil, ""}) end
      assert_raise ArgumentError, fn -> Email.to(Email.new(), {"", ""}) end
    end
  end

  describe "put_to/2" do
    test "should replace recipient" do
      email = Email.new()
      |> Email.to("foo.bar@example.com")
      |> Email.put_to(@to)

      assert email == %Email{to: [{"", @to}]}

      to    = {@name, @to}
      email = Email.put_to(email, to)

      assert email == %Email{to: [to]}

      email = Email.put_to(email, [@to, to])

      assert email == %Email{to: [{"", @to}, to]}
    end

    test "should raise if recipient(s) are invalid" do
      assert_raise ArgumentError, fn -> Email.put_to(Email.new(), nil) end
      assert_raise ArgumentError, fn -> Email.put_to(Email.new(), "") end
      assert_raise ArgumentError, fn -> Email.put_to(Email.new(), {nil, @to}) end
      assert_raise ArgumentError, fn -> Email.put_to(Email.new(), [nil, @to]) end
      assert_raise ArgumentError, fn ->
        Email.put_to(Email.new(), [{@name, nil}, @to])
      end
    end
  end

  describe "cc/2" do
    test "should put only an email address and an empty name" do
      email = Email.cc(Email.new(), @cc)

      assert email == %Email{cc: [{"", @cc}]}
    end

    test "should put both an email address and a name" do
      cc    = {@name, @cc}
      email = Email.cc(Email.new(), cc)

      assert email == %Email{cc: [cc]}
    end

    test "should put multiple recipients" do
      cc    = {@name, @cc}
      email = Email.cc(Email.new(), [@cc, cc])

      assert email == %Email{cc: [{"", @cc}, cc]}
    end

    test "should raise if a sender is invalid" do
      assert_raise ArgumentError, fn -> Email.cc(Email.new(), nil) end
      assert_raise ArgumentError, fn -> Email.cc(Email.new(), "") end
      assert_raise ArgumentError, fn -> Email.cc(Email.new(), {nil, nil}) end
      assert_raise ArgumentError, fn -> Email.cc(Email.new(), {nil, @cc}) end
      assert_raise ArgumentError, fn -> Email.cc(Email.new(), {nil, ""}) end
      assert_raise ArgumentError, fn -> Email.cc(Email.new(), {"", ""}) end
    end
  end

  describe "put_cc/2" do
    test "should replace recipient" do
      email = Email.new()
      |> Email.cc("foo.bar@example.com")
      |> Email.put_cc(@cc)

      assert email == %Email{cc: [{"", @cc}]}

      cc    = {@name, @cc}
      email = Email.put_cc(email, cc)

      assert email == %Email{cc: [cc]}

      email = Email.put_cc(email, [@cc, cc])

      assert email == %Email{cc: [{"", @cc}, cc]}
    end

    test "should raise if recipient(s) are invalid" do
      assert_raise ArgumentError, fn -> Email.put_cc(Email.new(), nil) end
      assert_raise ArgumentError, fn -> Email.put_cc(Email.new(), "") end
      assert_raise ArgumentError, fn -> Email.put_cc(Email.new(), {nil, @cc}) end
      assert_raise ArgumentError, fn -> Email.put_cc(Email.new(), [nil, @cc]) end
      assert_raise ArgumentError, fn ->
        Email.put_cc(Email.new(), [{@name, nil}, @cc])
      end
    end
  end

  describe "bcc/2" do
    test "should put only an email address and an empty name" do
      email = Email.bcc(Email.new(), @bcc)

      assert email == %Email{bcc: [{"", @bcc}]}
    end

    test "should put both an email address and a name" do
      bcc   = {@name, @bcc}
      email = Email.bcc(Email.new(), bcc)

      assert email == %Email{bcc: [bcc]}
    end

    test "should put multiple recipients" do
      bcc   = {@name, @bcc}
      email = Email.bcc(Email.new(), [@bcc, bcc])

      assert email == %Email{bcc: [{"", @bcc}, bcc]}
    end

    test "should raise if a sender is invalid" do
      assert_raise ArgumentError, fn -> Email.bcc(Email.new(), nil) end
      assert_raise ArgumentError, fn -> Email.bcc(Email.new(), "") end
      assert_raise ArgumentError, fn -> Email.bcc(Email.new(), {nil, nil}) end
      assert_raise ArgumentError, fn -> Email.bcc(Email.new(), {nil, @bcc}) end
      assert_raise ArgumentError, fn -> Email.bcc(Email.new(), {nil, ""}) end
      assert_raise ArgumentError, fn -> Email.bcc(Email.new(), {"", ""}) end
    end
  end

  describe "put_bcc/2" do
    test "should replace recipient" do
      email = Email.new()
      |> Email.bcc("foo.bar@example.com")
      |> Email.put_bcc(@bcc)

      assert email == %Email{bcc: [{"", @bcc}]}

      bcc   = {@name, @bcc}
      email = Email.put_bcc(email, bcc)

      assert email == %Email{bcc: [bcc]}

      email = Email.put_bcc(email, [@bcc, bcc])

      assert email == %Email{bcc: [{"", @bcc}, bcc]}
    end

    test "should raise if recipient(s) are invalid" do
      assert_raise ArgumentError, fn -> Email.put_bcc(Email.new(), nil) end
      assert_raise ArgumentError, fn -> Email.put_bcc(Email.new(), "") end
      assert_raise ArgumentError, fn -> Email.put_bcc(Email.new(), {nil, @bcc}) end
      assert_raise ArgumentError, fn -> Email.put_bcc(Email.new(), [nil, @bcc]) end
      assert_raise ArgumentError, fn ->
        Email.put_bcc(Email.new(), [{@name, nil}, @bcc])
      end
    end
  end

  describe "reply_to/2" do
    test "should put only an email address and an empty name" do
      email = Email.reply_to(Email.new(), @reply_to)

      assert email == %Email{reply_to: {"", @reply_to}}
    end

    test "should put both an email address and a name" do
      reply_to = {@name, @reply_to}
      email    = Email.reply_to(Email.new(), reply_to)

      assert email == %Email{reply_to: reply_to}
    end

    test "should raise if a recipient is invalid" do
      assert_raise ArgumentError, fn -> Email.reply_to(Email.new(), nil) end
      assert_raise ArgumentError, fn -> Email.reply_to(Email.new(), "") end
      assert_raise ArgumentError, fn -> Email.reply_to(Email.new(), {nil, nil}) end
      assert_raise ArgumentError, fn -> Email.reply_to(Email.new(), {nil, @reply_to}) end
      assert_raise ArgumentError, fn -> Email.reply_to(Email.new(), {nil, ""}) end
      assert_raise ArgumentError, fn -> Email.reply_to(Email.new(), {"", ""}) end
    end
  end

  describe "put_headers/3" do
    test "should put header" do
      email = Email.put_headers(Email.new(), "X-Accept-Language", "pl")

      assert email == %Email{headers: @headers}

      email = Email.put_headers(email, "X-Mailer", "ex_postmark")

      assert email == %Email{headers: %{"X-Accept-Language" => "pl", "X-Mailer" => "ex_postmark"}}
    end

    test "should raise if a header is invalid" do
      assert_raise ArgumentError, fn -> Email.put_headers(Email.new(), "X-Accept-Language", nil) end
      assert_raise ArgumentError, fn -> Email.put_headers(Email.new(), nil, "en") end
      assert_raise ArgumentError, fn -> Email.put_headers(Email.new(), nil, nil) end
    end
  end

  describe "template_id" do
    test "should put a template ID from an integer" do
      email = Email.template_id(Email.new(), @template_id)

      assert email == %Email{template_id: @template_id}
    end
    test "should put a template ID from a string" do
      email = Email.template_id(Email.new(), to_string(@template_id))

      assert email == %Email{template_id: @template_id}
    end

    test "should raise if a template ID is invalid" do
      assert_raise ArgumentError, fn -> Email.template_id(Email.new(), 0) end
      assert_raise ArgumentError, fn -> Email.template_id(Email.new(), "") end
      assert_raise ArgumentError, fn -> Email.template_id(Email.new(), nil) end
    end
  end

  describe "put_template_model/3" do
    test "should put a template model" do
      email = Email.put_template_model(Email.new(), :name, @name)

      assert email == %Email{template_model: %{name: @name}}

      email = Email.put_template_model(email, :team, "Bar")

      assert email == %Email{template_model: %{name: @name, team: "Bar"}}
    end

    test "should raise if a template model is invalid" do
      assert_raise ArgumentError, fn -> Email.put_template_model(Email.new(), "", nil) end
      assert_raise ArgumentError, fn -> Email.put_template_model(Email.new(), nil, nil) end
    end
  end
end
