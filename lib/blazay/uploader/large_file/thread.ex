defmodule Blazay.Uploader.LargeFile.Thread do
  @moduledoc """
  Responsible for preparing the thread data for uploading
  """

  defstruct [:part_url, :checksum, :content_length]

  alias Blazay.B2.Upload
  alias Upload.PartUrl

  @type t :: %__MODULE__{
    checksum: String.t,
    content_length: integer,
    part_url: PartUrl.t,
  }

  def prepare(file_id, chunk) do
    %__MODULE__{
      part_url: get_part_url(file_id),
      checksum: calculate_sha(chunk),
      content_length: calculate_length(chunk)
    }
  end

  defp calculate_sha(chunk) do
    chunk
    |> Enum.reduce(:crypto.hash_init(:sha), fn(bytes, acc) ->
      :crypto.hash_update(acc, bytes)
    end)
    |> :crypto.hash_final
    |> Base.encode16
    |> String.downcase
  end

  defp calculate_length(chunk) do
    chunk
    |> Stream.map(&byte_size/1)
    |> Enum.sum
  end

  defp get_part_url(file_id) do
    {:ok, part_url} = Upload.part_url(file_id)
    part_url
  end
end
