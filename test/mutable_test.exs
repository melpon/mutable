defmodule MutableTest do
  use ExUnit.Case, async: true
  doctest Mutable

  test "get() return empty out of mutation" do
    assert [] == Mutable.get()
  end

  test "The return value of Mutable.run/2 is same as the return value of fun" do
    result =
      Mutable.run([], fn ->
        100
      end)
    assert 100 == result
  end

  test "KeyError occurs when trying to acquire a key that does not exist" do
    Mutable.run([], fn ->
      assert [] == Mutable.get()
      assert_raise KeyError, fn -> Mutable.get(:x) end
    end)
  end

  test "can put and set values" do
    Mutable.run([x: 10], fn ->
      assert 10 == Mutable.get(:x)
      assert 10 == Mutable.put(:x, 20)
      assert 20 == Mutable.get(:x)
    end)
  end

  test "When get/0 is called in Mutable.run/1, all values are returned" do
    Mutable.run([x: 10, y: 20], fn ->
      assert Keyword.equal?([x: 10, y: 20], Mutable.get())
      Mutable.run([y: 30, z: 40], fn ->
        assert Keyword.equal?([x: 10, y: 30, z: 40], Mutable.get())
      end)
      assert Keyword.equal?([x: 10, y: 20], Mutable.get())
    end)
  end

  test "When it comes out of the nest, the original value is restored" do
    Mutable.run([x: 10, y: 20], fn ->
      Mutable.put(:y, 25)
      Mutable.run([y: 30, z: 40], fn ->
        :ok
      end)
      assert 25 == Mutable.get(:y)
    end)
  end

  test "When it comes out of the nest, it will not be able to get the value it used in the nest" do
    Mutable.run([x: 10, y: 20], fn ->
      Mutable.run([y: 30, z: 40], fn ->
        :ok
      end)
      assert_raise KeyError, fn -> Mutable.get(:z) end
    end)
  end

  test "It does not cause leak even if raise" do
    try do
      Mutable.run([x: 10, y: 20], fn ->
        Mutable.run([y: 30, z: 40], fn ->
          raise "test error"
        end)
      end)
    rescue
      _ -> :ok
    end

    assert [] == Mutable.get()
  end

  test "update/2 updates a value" do
    Mutable.run([x: 10], fn ->
      assert {11, 10} == Mutable.update(:x, &(&1 + 1))
      assert 11 == Mutable.get(:x)
    end)
  end
end
