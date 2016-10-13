defmodule ExPostmark.Adapters.Local.StorageTest do
  use ExUnit.Case, async: true

  alias ExPostmark.Adapters.Local.Storage

  setup do
    Storage.start_link()
    Storage.delete_all()
    :ok
  end

  test "starts with an empty mailbox" do
    assert Storage.all() == []
  end

  test "push an email into the mailbox" do
    Storage.push(%ExPostmark.Email{})

    assert Enum.count(Storage.all()) == 1
  end

  test "get an email from the mailbox" do
    Storage.push(%ExPostmark.Email{})
    %ExPostmark.Email{headers: %{"Message-ID" => id}} = Storage.push(%ExPostmark.Email{template_id: 1})
    Storage.push(%ExPostmark.Email{})

    assert %ExPostmark.Email{template_id: 1} = Storage.get(id)
  end

  test "pop an email from the mailbox" do
    Storage.push(%ExPostmark.Email{template_id: 1})
    Storage.push(%ExPostmark.Email{template_id: 2})

    assert Enum.count(Storage.all()) == 2

    email = Storage.pop()

    assert email.template_id == 2
    assert Enum.count(Storage.all()) == 1

    email = Storage.pop()

    assert email.template_id == 1
    assert Enum.count(Storage.all()) == 0
  end

  test "delete all the emails in the mailbox" do
    Storage.push(%ExPostmark.Email{})
    Storage.push(%ExPostmark.Email{})

    Storage.delete_all()

    assert Enum.count(Storage.all()) == 0
  end
end
