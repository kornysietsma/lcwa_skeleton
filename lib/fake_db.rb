class FakeDb
  def initialize(path, default_data)
    @path = path
    @default_data = default_data
    raise "no default datafile #{default_data}" unless File.exists?(default_data)
    @data = nil
    if File.exists?(@path)
      load_from_file(@path)
    else
      reset_to_default
    end
  end
  def reset_to_default
    load_from_file(@default_data)
    persist
  end
  def load_from_file(file)
    load_all(JSON.parse(File.read(file)))
  end
  def load_all(data)
    @data = data
  end
  def persist
    dir = File.dirname(@path)
    Dir.mkdir(dir) unless File.exists?(dir)
    File.open(@path,"w") do |f|
      f.puts @data.to_json
    end
  end
  def all_widgets
    @data["widgets"].collect {|key, value| {:id => key, :name => value["name"]}}
  end
  def widget(id, params = {})
    params = {:with_sprockets => false}.merge(params)
    return nil unless @data["widgets"].has_key? id
    if params[:with_sprockets]
      return {:id => id, :name => @data["widgets"][id]["name"], :sprockets => sprockets(id)}
    else
      return {:id => id, :name => @data["widgets"][id]["name"]}
    end
  end
  def sprockets(widget_id)
    return nil unless @data["widgets"].has_key? widget_id
    @data["widgets"][widget_id]["sprockets"].collect {|key, value| {:id => key, :name => value["name"], :size => value["size"]}}
  end

end