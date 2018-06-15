defmodule Upstream.B2.UploadTest do
  @moduledoc """
  false
  """
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias Upstream.B2.{
    LargeFile,
    Upload,
    Delete
  }

  setup_all do
    {:ok, %{file_name: "test_file.txt"}}
  end

  test "get the part_url", %{file_name: file_name} do
    use_cassette "b2_get_upload_part_url" do
      {:ok, started} = LargeFile.start(file_name)
      {:ok, part_url} = Upload.part_url(started.file_id)

      assert is_binary(part_url.upload_url)
      assert part_url.file_id == started.file_id
    end
  end

  test "get upload_url" do
    use_cassette "b2_get_upload_url" do
      {:ok, url} = Upload.url()

      assert is_binary(url.upload_url)
    end
  end

  test "upload file", %{file_name: file_name} do
    # generate an arbitary stream of data in this case 10_000 bytes

    # this test doesn't work because it uses async request from hackney which isn't
    # supported by ExVCR, but it's here for reference purposes
    # you can try this out on iex.
    # once i have some time I will create a PR for this
    stream = Stream.map(1..10_000, fn n -> <<n>> end)

    sha1 =
      stream
      |> Enum.reduce(:crypto.hash_init(:sha), fn bytes, acc ->
        :crypto.hash_update(acc, bytes)
      end)
      |> :crypto.hash_final()
      |> Base.encode16()
      |> String.downcase()

    {:ok, url} = Upload.url()

    header = %{
      authorization: url.authorization_token,
      file_name: file_name,
      content_length: 10_000,
      x_bz_content_sha1: sha1
    }

    {:ok, file} = Upload.file(url.upload_url, header, stream)
    assert file.action == "upload"

    Delete.file_version(file_name, file.file_id)
  end
end
