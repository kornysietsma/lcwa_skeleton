class Widget < Mongomatic::Base
  def self.populate_sample_data(data_file)
    raw_data = JSON.parse(File.read(data_file))
    raw_data["widgets"].each do |id, data|
      widget = Widget.new(:_id => id, :name => data["name"])
      sprockets = {}
      data["sprockets"].each do |sprocket_id, sprocket_data|
        sprockets[sprocket_id] = sprocket_data
      end
      widget["sprockets"] = sprockets
      widget.insert
    end
    collection.create_index("name", :unique => true)
  end
end