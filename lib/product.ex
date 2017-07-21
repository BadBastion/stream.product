defmodule Product do

  # def next_pair(%{dir: dir, x: x, y: y} = old_pair) do
  #   if x > 1 && y > 1,
  #   do: %{dir: dir, x: x+dir, y: y-dir},
  #   else: if x < y,
  #       do: %{dir: (dir * -1), x: x+1, y: y},
  #       else: %{dir: (dir * -1), x: x, y: y+1}
  # end
  #
  # def do_pairs(pair) do
  #   new_pair = pair|> next_pair
  #   IO.inspect(new_pair)
  #   do_pairs(new_pair)
  # end
  # def pairs() do
  #   do_pairs(next_pair(%{dir: 1, x: 1, y: 1}))
  # end

  def next(enums, root_enums) do
    {overflow, enums, _} =
      enums
      |> List.foldl({true, [], root_enums}, fn
        [_ | []],   {true,  acc, [ root | root_enums]} -> {true,  [root | acc], root_enums}
        [_ | tail], {true,  acc, [_root | root_enums]} -> {false, [tail | acc], root_enums}
        enum,       {false, acc, [_root | root_enums]} -> {false, [enum | acc], root_enums}
      end)

    {overflow, Enum.reverse(enums)}
  end


  def next(cursor, head) do
      Stream.zip(cursor, head)
      |> List.foldr({true, []}, fn
        {[_ | []],    head}, {true,  acc} -> {true,  [head | acc]}
        {[_ | tail], _head}, {true,  acc} -> {false, [tail | acc]}
        {enum, _head},       {false, acc} -> {false, [enum | acc]}
      end)
  end

  def unique_next(enums, root_enums, scopes, root_scopes) do
    case next(enums, root_enums) do
      {true, _} ->
        {overflow, scopes} = next(scopes, root_scopes)
        {overflow, cursor(scopes), cursor(scopes), scopes}
      {false, enums} ->
        {false, enums, root_enums, scopes}
    end
  end

  def cursor(enums) do
    enums
    |> Enum.map(fn [head | _] -> head end)
  end


  def do_example(enums, root_enums, scopes, root_scopes, acc) do
    case unique_next(enums, root_enums, scopes, root_scopes) do
      {false, enums, root_enums, scopes} ->
        do_example(enums, root_enums, scopes, root_scopes, [cursor(enums) | acc])
      {true, _, _, _} -> acc
    end
  end

  def example(enums) do
    root_scopes = Enum.map(enums, fn
      [nil | tail] -> [Enum.reverse(tail)]
      [head | tail] -> [Enum.reverse(tail), [head]]
    end)
    {false, scopes} = next(root_scopes, root_scopes)
    root_enums = cursor(scopes)

    do_example(root_enums, root_enums, scopes, root_scopes, [cursor(root_enums)])
  end





@spec product(Enumerable.t, Enumerable.t) :: Enumerable.t
  def product(left, right) do
    product([left, right])
  end

  def product(enum) do
    step = &do_product_step(&1, &2)

  end

  defp do_product_step(x, []) do
    {:cont, [x]}
  end

  defp do_product(products, {:halt, acc}, _fun) do
    do_zip_close(products)
    {:halted, acc}
  end

  defp do_product(products, {:suspend, acc}, fun) do
    {:suspended, acc, &do_zip(products, &1, fun)}
  end

  defp do_product(products, {:cont, acc}, callback) do
    try do
      do_zip_next_tuple(products, acc, callback, [], [])
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

  defp do_product_close(products) do
    :lists.foreach(fn {fun, _} -> fun.({:halt, []}) end, products)
  end

#
# defp product_next() do
#
# end
#
#
#
#
#
  def map(map_func) do
      fn elem, acc ->
        acc ++ [ map_func.(elem) ]
      end
  end
#
#   end
#
#   @spec zip(Enumerable.t, Enumerable.t) :: Enumerable.t
#   def zip(left, right), do: zip([left, right])
#
#   @doc """
#   Zips corresponding elements from a collection of enumerables
#   into one stream of tuples.
#   The zipping finishes as soon as any enumerable completes.
#   ## Examples
#       iex> concat = Stream.concat(1..3, 4..6)
#       iex> cycle = Stream.cycle(["foo", "bar", "baz"])
#       iex> Stream.zip([concat, [:a, :b, :c], cycle]) |> Enum.to_list
#       [{1, :a, "foo"}, {2, :b, "bar"}, {3, :c, "baz"}]
#   """
#   @spec zip([Enumerable.t]) :: Enumerable.t
#   def zip(enumerables) do
#     step      = &do_zip_step(&1, &2)
#     enum_funs = Enum.map(enumerables, fn enum ->
#       {&Enumerable.reduce(enum, &1, step), :cont}
#     end)
#
#     &do_zip(enum_funs, &1, &2)
#   end
#
#   # This implementation of do_zip/3 works for any number of
#   # streams to zip, even if right now zip/2 only zips two streams.
#
#   defp do_zip(zips, {:halt, acc}, _fun) do
#     do_zip_close(zips)
#     {:halted, acc}
#   end
#
#   defp do_zip(zips, {:suspend, acc}, fun) do
#     {:suspended, acc, &do_zip(zips, &1, fun)}
#   end
#
#   defp do_zip(zips, {:cont, acc}, callback) do
#     try do
#       do_zip_next_tuple(zips, acc, callback, [], [])
#     catch
#       kind, reason ->
#         stacktrace = System.stacktrace
#         do_zip_close(zips)
#         :erlang.raise(kind, reason, stacktrace)
#     else
#       {:next, buffer, acc} ->
#         do_zip(buffer, acc, callback)
#       {:done, _acc} = other ->
#         other
#     end
#   end
#
#   # do_zip_next_tuple/5 computes the next tuple formed by
#   # the next element of each zipped stream.
#
#   defp do_zip_next_tuple([{_, :halt} | zips], acc, _callback, _yielded_elems, buffer) do
#     do_zip_close(:lists.reverse(buffer, zips))
#     {:done, acc}
#   end
#
#   defp do_zip_next_tuple([{fun, :cont} | zips], acc, callback, yielded_elems, buffer) do
#     case fun.({:cont, []}) do
#       {:suspended, [elem], fun} ->
#         do_zip_next_tuple(zips, acc, callback, [elem | yielded_elems], [{fun, :cont} | buffer])
#
#       {_, [elem]} ->
#         do_zip_next_tuple(zips, acc, callback, [elem | yielded_elems], [{fun, :halt} | buffer])
#
#       {_, []} ->
#         # The current zipped stream terminated, so we close all the streams
#         # and return {:halted, acc} (which is returned as is by do_zip/3).
#         do_zip_close(:lists.reverse(buffer, zips))
#         {:done, acc}
#     end
#   end
#
#   defp do_zip_next_tuple([] = _zips, acc, callback, yielded_elems, buffer) do
#     # "yielded_elems" is a reversed list of results for the current iteration of
#     # zipping: it needs to be reversed and converted to a tuple to have the next
#     # tuple in the list resulting from zipping.
#     zipped = List.to_tuple(:lists.reverse(yielded_elems))
#     {:next, :lists.reverse(buffer), callback.(zipped, acc)}
#   end
#
#   defp do_zip_close(zips) do
#     :lists.foreach(fn {fun, _} -> fun.({:halt, []}) end, zips)
#   end
#
#   defp do_zip_step(x, []) do
#     {:suspend, [x]}
#   end




  # defp lazy(%Stream{done: nil, funs: funs} = lazy, fun),
  #   do: %{lazy | funs: [fun | funs]}
  # defp lazy(enum, fun),
  #   do: %Stream{enum: enum, funs: [fun]}
  #
  # defp lazy(%Stream{done: nil, funs: funs, accs: accs} = lazy, acc, fun),
  #   do: %{lazy | funs: [fun | funs], accs: [acc | accs]}
  # defp lazy(enum, acc, fun),
  #   do: %Stream{enum: enum, funs: [fun], accs: [acc]}
  #
  # defp lazy(%Stream{done: nil, funs: funs, accs: accs} = lazy, acc, fun, done),
  #   do: %{lazy | funs: [fun | funs], accs: [acc | accs], done: done}
  # defp lazy(enum, acc, fun, done),
  #   do: %Stream{enum: enum, funs: [fun], accs: [acc], done: done}
  #
  # defmacrop next(fun, entry, acc) do
  #   quote do: unquote(fun).(unquote(entry), unquote(acc))
  # end
  #
  #
  #
  #
  #
  #
  #
  #
  # @moduledoc """
  # Documentation for Product.
  # """
  # def product(left, right), do: product([left, right])
  #
  # def zip(enumerables) do
  #   step      = &do_zip_step(&1, &2)
  #
  #   enum_funs = Enum.map(enumerables, fn enum ->
  #     {&Enumerable.reduce(enum, &1, step), :cont}
  #   end)
  #
  #   &do_zip(enum_funs, &1, &2)
  # end
  #
  # # streams to zip, even if right now zip/2 only zips two streams.
  #
  # defp do_zip(zips, {:halt, acc}, _fun) do
  #   do_zip_close(zips)
  #   {:halted, acc}
  # end
  #
  # defp do_zip(zips, {:suspend, acc}, fun) do
  #   {:suspended, acc, &do_zip(zips, &1, fun)}
  # end
  #
  # defp do_zip(zips, {:cont, acc}, callback) do
  #   try do
  #     do_zip_next_tuple(zips, acc, callback, [], [])
  #   catch
  #     kind, reason ->
  #       stacktrace = System.stacktrace
  #       do_zip_close(zips)
  #       :erlang.raise(kind, reason, stacktrace)
  #   else
  #     {:next, buffer, acc} ->
  #       do_zip(buffer, acc, callback)
  #     {:done, _acc} = other ->
  #       other
  #   end
  # end
  #
  # # do_zip_next_tuple/5 computes the next tuple formed by
  # # the next element of each zipped stream.
  #
  # defp do_zip_next_tuple([{_, :halt} | zips], acc, _callback, _yielded_elems, buffer) do
  #   do_zip_close(:lists.reverse(buffer, zips))
  #   {:done, acc}
  # end
  #
  # defp do_zip_next_tuple([{fun, :cont} | zips], acc, callback, yielded_elems, buffer) do
  #   case fun.({:cont, []}) do
  #     {:suspended, [elem], fun} ->
  #       do_zip_next_tuple(zips, acc, callback, [elem | yielded_elems], [{fun, :cont} | buffer])
  #     {_, [elem]} ->
  #       do_zip_next_tuple(zips, acc, callback, [elem | yielded_elems], [{fun, :halt} | buffer])
  #     {_, []} ->
  #       # The current zipped stream terminated, so we close all the streams
  #       # and return {:halted, acc} (which is returned as is by do_zip/3).
  #       do_zip_close(:lists.reverse(buffer, zips))
  #       {:done, acc}
  #   end
  # end
  #
  # defp do_zip_next_tuple([] = _zips, acc, callback, yielded_elems, buffer) do
  #   # "yielded_elems" is a reversed list of results for the current iteration of
  #   # zipping: it needs to be reversed and converted to a tuple to have the next
  #   # tuple in the list resulting from zipping.
  #   zipped = List.to_tuple(:lists.reverse(yielded_elems))
  #   {:next, :lists.reverse(buffer), callback.(zipped, acc)}
  # end
  #
  # defp do_zip_close(zips) do
  #   :lists.foreach(fn {fun, _} -> fun.({:halt, []}) end, zips)
  # end
  #
  # defp do_zip_step(x, []) do
  #   {:suspend, [x]}
  # end
end
