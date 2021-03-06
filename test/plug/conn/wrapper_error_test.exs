defmodule Plug.Conn.WrapperErrorTest do
  use ExUnit.Case, async: true
  use Plug.Test

  test "reraise/3" do
    conn = conn(:get, "/")
    err  = RuntimeError.exception("hello")
    {wrap, stacktrace} = catch_error_stacktrace(fn -> Plug.Conn.WrapperError.reraise(conn, :error, err) end)
    assert wrap.conn == conn
    assert wrap.kind == :error
    assert wrap.reason == err
    assert wrap.stack == stacktrace
    assert catch_error(Plug.Conn.WrapperError.reraise(:whatever, :error, wrap)) == wrap
  end

  test "reraise/3 does not change exits or throws" do
    assert catch_throw(Plug.Conn.WrapperError.reraise(conn(:get, "/"), :throw, :oops)) == :oops
    assert catch_exit(Plug.Conn.WrapperError.reraise(conn(:get, "/"), :exit, :oops)) == :oops
  end

  defp catch_error_stacktrace(fun) do
    fun.()
    flunk "Expected to catch error, got nothing"
  catch
    :error, error ->
      {error, System.stacktrace()}
  end
end
