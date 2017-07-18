defmodule Product do



  def increment_cursor(cursor, depth, max, carry) do
        cursor
        |> List.foldr(
          {carry, false, []},
          fn elem, {carry, unique, acc} ->
            case elem + carry do
              ^depth -> {1, unique, [0   | acc]}
              ^max   -> {0, true  , [max | acc]}
               sum   -> {0, unique, [sum | acc]}
            end
          end)
    end


  def next(enums, roots) do
    enums
    |> List.foldr({true, [], roots},
      fn [_ | []],   {true,  acc, [ root | roots]} ->  {true,  [root | acc], roots}
         [_ | tail], {true,  acc, [_root | roots]} -> {false, [tail | acc], roots}
         enum,       {false, acc, [_root | roots]} -> {false, [enum | acc], roots}
      end)
  end

  def unique_next(enums, roots, scope, scope_roots) do
    case next(enums, roots) do
      {true, _, _} ->
        {overflow, scopes, _} = next(scope, scope_roots)
        {overflow, Enum.map(scopes, fn [head | _] -> [head] end), scopes}
      {false, enums, _} ->
        {false, enums, scope}
    end
  end

  def create_cursor(enums) do
    enums
    |> Enum.map(fn [head | _] -> head end)
    |> List.to_tuple
  end

  def do_example(enums, roots, scope, scope_roots, acc) do
    case unique_next(enums, roots, scope, scope_roots) do
      {false, enums, scope} ->
        do_example(enums, roots, scope, scope_roots, [create_cursor(enums) | acc])
      {true, _, _} -> acc
    end
  end

  def example(enums) do
    scope = Enum.map(enums, fn [head | tail] -> [head, tail] end)
    do_example(enums, enums, scope, scope, [create_cursor(enums)])
  end

# @spec product(Enumerable.t, Enumerable.t) :: Enumerable.t
#   def product(left, right) do
#     step      = &do_product_step(&1, &2)
#
#     &Enumerable.reduce(enum, &1, step)
#   end
#
#   defp do_product_step(x, []) do
#     {:cont, [x]}
#   end
#
# defp product_next() do
#
# end
#
#
#
#
#
#   def map(fun) do
#
#     fn(f1) ->
#       fn entry, acc ->
#         f1.(fun.(entry), acc)
#       end
#     end
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
