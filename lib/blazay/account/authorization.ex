defmodule Blazay.Account.Authorization do
  defstruct [
    :account_id, 
    :authorization_token, 
    :api_url, 
    :download_url,
    :recommended_part_size,
    :absolute_minimum_part_size
  ]

  @type t :: %__MODULE__{
    account_id: String.t,
    authorization_token: String.t,
    api_url: String.t,
    download_url: String.t,
    recommended_part_size: integer,
    absolute_minimum_part_size: integer
  }
  @doc """
  Authorize#call function will make a call to the api and authorize based on the
  account_id, and application_key passed in from the config.

  config :blazay, Blazay, 
    account_id: <whatever account_id>,
    application_key: <whatever application_key>
  """
  alias Blazay.Request

  @doc """
  the Request.Caller macro sets up the `call` function for this module
  """
  use Request.Caller

  def url, do: Url.generate(:authorize_account)
    
  def header do
    encoded = "Basic " <> Base.encode64(
      Blazay.config(:account_id) <> ":" <> Blazay.config(:application_key)
    )
    
    [{"Authorization", encoded}]
  end
end