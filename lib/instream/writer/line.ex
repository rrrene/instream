defmodule Instream.Writer.Line do
  @moduledoc """
  Point writer for the line protocol.
  """

  use Instream.Writer

  alias Instream.Encoder.Line, as: Encoder
  alias Instream.Query.Headers
  alias Instream.Query.URL


  def write(query, opts, conn) do
    headers = Headers.assemble(conn) ++ [{ 'Content-Type', 'text/plain' }]
    body    = query.payload |> to_line()

    db  = opts[:database] || Map.get(query.payload, :database)
    url =
         conn
      |> URL.write()
      |> URL.append_database(db)
      |> URL.append_precision(query.opts[:precision])

    http_opts = Keyword.get(conn, :http_opts, [])

    { :ok, status, headers, client } = :hackney.post(url, headers, body, http_opts)
    { :ok, response }                = :hackney.body(client)

    { status, headers, response }
  end

  defp to_line(payload), do: payload |> Map.get(:points, []) |> Encoder.encode()
end
