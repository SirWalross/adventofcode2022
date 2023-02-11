start = 14
{_, index} = String.split(File.read!("input"), "", trim: true) |> Enum.chunk_every(start, 1, :discard) |> Enum.map(&Enum.frequencies/1) |> Enum.with_index() |> Enum.find(fn {map, _} -> Enum.all?(map, fn {_, v} -> v == 1 end) end)
IO.puts(start + index)
