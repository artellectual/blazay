defmodule Upstream.B2.Routes do
  @moduledoc """
  Provides the Endpoints for uploading
  """

  import Upstream.Endpoint

  use Plug.Router

  alias Upstream.B2

  plug(B2.Account.AuthorizationPlug)


  plug(
    Plug.Parsers,
    parsers: [:multipart],
    pass: ["*/*"],
    length: 100_000_000
  )

  plug(:match)
  plug(:dispatch)


  get "/chunks/unfinished" do
    case B2.LargeFile.unfinished(conn.assigns.auth) do
      {:ok, unfinished} ->
        render_json(conn, 200, unfinished)

      {:error, reason} ->
        render_json(conn, 422, reason)
    end
  end

  get "/chunks/resume/:file_id" do
    case B2.LargeFile.ListParts.call(conn.assigns.auth, body: file_id) do
      {:ok, %B2.LargeFile.ListParts{parts: parts}} ->
        shas = B2.LargeFile.ListParts.extract_shas(parts)
        render_json(conn, 200, %{shas: shas})

      {:error, reason} ->
        render_json(conn, 422, reason)
    end
  end

  post "/file" do
    %{"file_name" => file_name} = conn.body_params

    %{path: path, filename: _filename} = conn.body_params[Upstream.file_param()]

    case B2.upload_file(conn.assigns.auth, path, file_name) do
      {:ok, result} ->
        render_json(conn, 200, merge_success(result))

      {:error, reason} ->
        render_json(conn, 422, merge_fail(reason))
    end
  end

  post "/chunks/start" do
    %{"file_name" => file_name} = conn.body_params

    case B2.LargeFile.start(conn.assigns.auth, file_name) do
      {:ok, start} ->
        render_json(conn, 201, start)

      {:error, reason} ->
        render_json(conn, 422, reason)
    end
  end

  delete "/chunks/cancel/:file_id" do
    case B2.LargeFile.cancel(conn.assigns.auth, file_id) do
      {:ok, cancel} ->
        render_json(conn, 200, cancel)

      {:error, reason} ->
        render_json(conn, 422, reason)
    end
  end

  patch "/chunks/add" do
    %{"file_id" => file_id,
      "part_number" => part_number,
      "chunk_size" => chunk_size} = conn.body_params

    %{path: path, filename: _filename} = conn.body_params[Upstream.file_param()]

    upload_params = %{
      file_id: file_id,
      index: String.to_integer(part_number),
      content_length: String.to_integer(chunk_size),
      attempt: String.to_integer(conn.body_params["attempt"] || "0")
    }

    case B2.upload_chunk(conn.assigns.auth, path, upload_params) do
      {:ok, result} ->
        render_json(conn, 200, merge_success(result))

      {:error, reason} ->
        render_json(conn, 422, merge_fail(reason))
    end
  end

  post "/chunks/finish" do
    %{"file_id" => file_id, "shas" => shas} = conn.body_params

    shas_list =
      shas
      |> Enum.sort_by(fn {k, _v} -> Integer.parse(k) end)
      |> Enum.map(fn {_k, v} -> v end)

    case B2.LargeFile.finish(conn.assigns.auth, file_id, shas_list) do
      {:ok, result} ->
        render_json(conn, 200, merge_success(result))

      {:error, reason} ->
        render_json(conn, 422, merge_fail(reason))
    end
  end
end
