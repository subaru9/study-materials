defmodule NaiveVerTest do
  use ExUnit.Case
  doctest NaiveVer

  test "greets the world" do
    assert NaiveVer.hello() == :world
  end
end
