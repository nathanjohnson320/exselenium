defmodule Selenium.Commands.Cookie do
  alias Selenium.Session
  alias Selenium.Request

  # A struct defining the Cookie JSON format
  defstruct [
    name: "",
    value: "",
    path: nil,
    domain: nil,
    secure: nil,
    httpOnly: nil,
    expiry: nil
  ]

  # Get all the cookies on a page
  def all(identifier) do
    session_id = Session.get(identifier)

    {:ok, %HTTPoison.Response{body: body,
                              headers: _,
                              status_code: _}} = Request.get("session/#{session_id}/cookie", [], [recv_timeout: Application.get_env(:selenium, :timeout), hackney: [pool: :driver_pool]])

    # Map the cookie response to cookie structs
    Enum.map body["value"], fn(cookie) ->
      %Selenium.Commands.Cookie{}
      |> Map.put(:name, cookie["name"])
      |> Map.put(:value, cookie["value"])
      |> Map.put(:path, cookie["path"])
      |> Map.put(:domain, cookie["domain"])
      |> Map.put(:secure, cookie["secure"])
      |> Map.put(:httpOnly, cookie["httpOnly"])
      |> Map.put(:expiry, cookie["expiry"])
    end
  end

  # Get a single cookie
  def get(identifier, name) do
    # Get all the cookies first, then filter them down by name
    all(identifier) |> Enum.find(fn(cookie) -> cookie.name == name end)
  end

  # Set a cookie to a value, use %Cookie{} for this
  def set(identifier, cookie) do
    session_id = Session.get(identifier)

    # Filter out the nil values from our struct
    cookie = for {k, v} <- Map.from_struct(cookie), v != nil, into: %{}, do: {k, v}

    {:ok, %HTTPoison.Response{body: body,
                              headers: _,
                              status_code: _}} = Request.post("session/#{session_id}/cookie", %{"cookie" => cookie}, [], [recv_timeout: Application.get_env(:selenium, :timeout), hackney: [pool: :driver_pool]])
    body
  end

  # Delete all the cookies
  def delete_all(identifier) do
    session_id = Session.get(identifier)

    {:ok, %HTTPoison.Response{body: body,
                              headers: _,
                              status_code: _}} = Request.delete("session/#{session_id}/cookie", [], [recv_timeout: Application.get_env(:selenium, :timeout), hackney: [pool: :driver_pool]])
    body
  end

  # Delete a cookie by name
  def delete(identifier, name) do
    session_id = Session.get(identifier)

    {:ok, %HTTPoison.Response{body: body,
                              headers: _,
                              status_code: _}} = Request.delete("session/#{session_id}/cookie/#{name}", [], [recv_timeout: Application.get_env(:selenium, :timeout), hackney: [pool: :driver_pool]])
    body["value"]
  end
end
