module FileHelpers
  def replace_in_file(path, find, replace)
    in_current_dir do
      contents = IO.read(path)
      contents.sub!(find, replace)
      File.open(path, "w") { |file| file.write(contents) }
    end
  end
end

World(FileHelpers)
