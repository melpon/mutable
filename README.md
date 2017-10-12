# Mutable

An elixir library that temporarily generates side effects.

## Usage

You can put and get the value into `Mutable.run/2`.

```elixir
Mutable.run([x: 10], fn ->
  assert 10 == Mutable.get(:x)
  Mutable.put(:x, 20)
  assert 20 == Mutable.get(:x)
  Mutable.update(:x, &(&1 + 1))
  assert 21 == Mutable.get(:x)
end)
```

`Mutable.run/2` is nestable.

```elixir
Mutable.run([x: 10], fn ->
  assert 10 == Mutable.get(:x)
  Mutable.run([x: 20], fn ->
    assert 20 == Mutable.get(:x)
  end)
  # the value is restored
  assert 10 == Mutable.get(:x)
end)
```
