defmodule Blazay do
  use Application
  @moduledoc """
  Blazay is a utility for working with file upload.
  It specifically integrates with backblaze b2 object store service.
  """

  @doc """
  Blazay.base_api returns the base api string

  ## Examples

    iex> Blazay.base_api
    "https://api.backblazeb2.com"
  """
  def start(_type, _args) do
    Blazay.Supervisor.start_link()
  end

  @b2_base_api ~S(https://api.backblazeb2.com)
  def base_api, do: @b2_base_api

  @config Application.get_env(:blazay, Blazay)
  def config, do: @config

  @concurrency 2
  def concurrency, do: config(:concurrency) || @concurrency

  @file_param "file"
  def file_param, do: config(:file_param) || @file_param

  @doc """
  Blazay.config/1 help you get to your config

  ## Examples

    iex> Blazay.config(:account_id)
    Keyword.fetch!(Blazay.config, :account_id)
  """
  def config(key), do: Keyword.get(config(), key, nil)
end
