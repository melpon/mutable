defmodule Mutable do
  @moduledoc """
  Temporary side-effect module
  """

  @mutable_key :mutable_key
  @mutable_undefined :mutable_undefined

  def run(keyword, fun) do
    for {key, value} <- keyword do
      push(key, value)
    end

    try do
      fun.()
    after
      for {key, _} <- keyword do
        pop(key)
      end
    end
  end

  defp push(key, value) do
    mkey = {@mutable_key, key}
    values = Process.get(mkey, [])
    Process.put(mkey, [value | values])
  end

  defp pop(key) do
    mkey = {@mutable_key, key}

    case Process.get(mkey, @mutable_undefined) do
      @mutable_undefined -> raise KeyError, key: key, term: get()
      [_] -> Process.delete(mkey)
      [_ | values] -> Process.put(mkey, values)
    end
  end

  def get() do
    Process.get()
    |> Enum.filter(fn
      {{@mutable_key, _key}, _values} -> true
      _ -> false
    end)
    |> Enum.map(fn {{@mutable_key, key}, [value | _]} -> {key, value} end)
  end

  def get(key) do
    mkey = {@mutable_key, key}

    case Process.get(mkey, @mutable_undefined) do
      @mutable_undefined -> raise KeyError, key: key, term: get()
      [value | _] -> value
    end
  end

  def put(key, value) do
    mkey = {@mutable_key, key}

    case Process.get(mkey, @mutable_undefined) do
      @mutable_undefined ->
        raise KeyError, key: key, term: get()

      [old_value | values] ->
        _ = Process.put(mkey, [value | values])
        old_value
    end
  end

  def update(key, fun) do
    value = get(key)
    new_value = fun.(value)
    put(key, new_value)
    {new_value, value}
  end
end
