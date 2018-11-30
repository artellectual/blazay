defmodule Upstream do
  @moduledoc """
  Upstream is a utility for working with file upload.
  It specifically integrates with backblaze b2 object store service.
  """

  require Logger

  @doc """
  Upstream.base_api returns the base api string

  ## Examples

    iex> Upstream.base_api
    "https://api.backblazeb2.com"
  """
  @b2_base_api ~S(https://api.backblazeb2.com)
  def base_api, do: @b2_base_api

  @spec config() :: any()
  def config, do: Application.get_env(:upstream, Upstream) || []
  @spec storage() :: any()
  def storage, do: Application.get_env(:upstream, :storage) || []

  @concurrency 2
  @spec concurrency() :: integer()
  def concurrency, do: config(:concurrency) || @concurrency

  @file_param "file"
  def file_param, do: config(:file_param) || @file_param

  @spec config(atom()) :: any()
  def config(key), do: Keyword.get(config(), key, nil)

  @spec storage(atom()) :: any()
  def storage(key), do: Keyword.get(storage(), key, nil)

  @spec reboot() :: {:error, {atom(), any()}} | {:ok, [atom()]}
  def reboot do
    Application.stop(:upstream)
    Application.ensure_all_started(:upstream)
  end

  @spec reset() :: {:error, {atom(), any()}} | {:ok, [atom()]}
  def reset do
    Logger.info("[Upstream] -----> Flushing config and restarting")
    Application.delete_env(:upstream, :storage)
    reboot()
  end

  @spec set_config(any()) :: {:error, {atom(), any()}} | {:ok, [atom()]}
  def set_config(config) do
    Logger.info("[Upstream] -----> Setting config and restarting")
    Application.put_env(:upstream, :storage, config)
    reboot()
  end
end
