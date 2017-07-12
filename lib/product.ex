defmodule Product do

  def map(enumerable, func) do
    lazy enum, fn(f1) ->
      fn(entry, acc) -> next(f1, func.(entry), acc) end
    end
  end




  defp lazy(%Stream{done: nil, funs: funs} = lazy, fun),
    do: %{lazy | funs: [fun | funs]}
  defp lazy(enum, fun),
    do: %Stream{enum: enum, funs: [fun]}

  defp lazy(%Stream{done: nil, funs: funs, accs: accs} = lazy, acc, fun),
    do: %{lazy | funs: [fun | funs], accs: [acc | accs]}
  defp lazy(enum, acc, fun),
    do: %Stream{enum: enum, funs: [fun], accs: [acc]}

  defp lazy(%Stream{done: nil, funs: funs, accs: accs} = lazy, acc, fun, done),
    do: %{lazy | funs: [fun | funs], accs: [acc | accs], done: done}
  defp lazy(enum, acc, fun, done),
    do: %Stream{enum: enum, funs: [fun], accs: [acc], done: done}




  @moduledoc """
  Documentation for Product.
  """
  def product(left, right), do: product([left, right])

  def zip(enumerables) do
    step      = &do_zip_step(&1, &2)

    enum_funs = Enum.map(enumerables, fn enum ->
      {&Enumerable.reduce(enum, &1, step), :cont}
    end)

    &do_zip(enum_funs, &1, &2)
  end

  # streams to zip, even if right now zip/2 only zips two streams.

  defp do_zip(zips, {:halt, acc}, _fun) do
    do_zip_close(zips)
    {:halted, acc}
  end

  defp do_zip(zips, {:suspend, acc}, fun) do
    {:suspended, acc, &do_zip(zips, &1, fun)}
  end

  defp do_zip(zips, {:cont, acc}, callback) do
    try do
      do_zip_next_tuple(zips, acc, callback, [], [])
    catch
      kind, reason ->
        stacktrace = System.stacktrace
        do_zip_close(zips)
        :erlang.raise(kind, reason, stacktrace)
    else
      {:next, buffer, acc} ->
        do_zip(buffer, acc, callback)
      {:done, _acc} = other ->
        other
    end
  end

  # do_zip_next_tuple/5 computes the next tuple formed by
  # the next element of each zipped stream.

  defp do_zip_next_tuple([{_, :halt} | zips], acc, _callback, _yielded_elems, buffer) do
    do_zip_close(:lists.reverse(buffer, zips))
    {:done, acc}
  end

  defp do_zip_next_tuple([{fun, :cont} | zips], acc, callback, yielded_elems, buffer) do
    case fun.({:cont, []}) do
      {:suspended, [elem], fun} ->
        do_zip_next_tuple(zips, acc, callback, [elem | yielded_elems], [{fun, :cont} | buffer])
      {_, [elem]} ->
        do_zip_next_tuple(zips, acc, callback, [elem | yielded_elems], [{fun, :halt} | buffer])
      {_, []} ->
        # The current zipped stream terminated, so we close all the streams
        # and return {:halted, acc} (which is returned as is by do_zip/3).
        do_zip_close(:lists.reverse(buffer, zips))
        {:done, acc}
    end
  end

  defp do_zip_next_tuple([] = _zips, acc, callback, yielded_elems, buffer) do
    # "yielded_elems" is a reversed list of results for the current iteration of
    # zipping: it needs to be reversed and converted to a tuple to have the next
    # tuple in the list resulting from zipping.
    zipped = List.to_tuple(:lists.reverse(yielded_elems))
    {:next, :lists.reverse(buffer), callback.(zipped, acc)}
  end

  defp do_zip_close(zips) do
    :lists.foreach(fn {fun, _} -> fun.({:halt, []}) end, zips)
  end

  defp do_zip_step(x, []) do
    {:suspend, [x]}
  end



end
