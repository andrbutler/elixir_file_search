defmodule FileSearch do
  @moduledoc """
  Documentation for FileSearch
  """
  def main(args) do
    {flags, path, _} = OptionParser.parse(args, switches: [byType: :boolean], alias: [])
    case {flags, path} do
      {[], []} -> IO.puts(all(elem(File.cwd(),1)) |> Enum.join(", "))
      {[], path} -> IO.puts(all(Path.absname(path)) |> Enum.join(", "))
      {[byType: true], []} -> by_extension(elem(File.cwd(),1)) 
      |> Enum.map(fn map -> 
        IO.puts("#{elem(map, 0)}: \n#{elem(map, 1) |> Enum.join(", ")}")
      end)
      {[byType: true], path} -> by_extension(Path.absname(path))
      |> Enum.map(fn map -> 
        IO.puts("#{elem(map, 0)}: \n#{elem(map, 1) |> Enum.join(", ")}")
      end)
    end
  end

  @doc """
  Find all nested files.

  For example, given the following folder structure
  /main
    /sub1
      file1.txt
    /sub2
      file2.txt
    /sub3
      file3.txt
    file4.txt

  It would return:

  ["file1.txt", "file2.txt", "file3.txt", "file4.txt"]
  """
  def all(folder) do
    {:ok, files} = File.ls(folder)

    crawl(files, folder)
    |> List.flatten()
  end

  @doc """
  helper function that crawls down from root folder to get all file names in child directories.
  """
  def crawl(file_list, root_folder) do
    Enum.map(file_list, fn file ->
      if File.dir?(Path.join(root_folder, file)) do
        all(Path.join(root_folder, file))
      else
        file
      end
    end)
  end

  @doc """
  Find all nested files and categorize them by their extension.

  For example, given the following folder structure
  /main
    /sub1
      file1.txt
      file1.png
    /sub2
      file2.txt
      file2.png
    /sub3
      file3.txt
      file3.jpg
    file4.txt

  The exact order and return value are up to you as long as it finds all files 
  and categorizes them by file extension.

  For example, it might return the following:

  %{
    ".txt" => ["file1.txt", "file2.txt", "file3.txt", "file4.txt"],
    ".png" => ["file1.png", "file2.png"],
    ".jpg" => ["file3.jpg"]
  }
  """
  def by_extension(folder) do
    all(folder)
    |> Enum.group_by(fn string ->
      cond do
        String.at(string, 0) == "." -> "dotFile"
        !String.contains?(string, ".") -> "noExtension"
        true -> List.last(String.split(string, "."))
      end
    end)
  end
end
