# Korny's simple extension to OpenStruct to build recursive OpenStructs from hashes and arrays

class OpenStruct
  def self.build_recursive(source)
    return case source
             when Hash
               results = source.inject({}) do |result, entry|
                 result[entry.first] = OpenStruct.build_recursive(entry.last)
                 result
               end
               return OpenStruct.new results
             when Array
               return source.collect { |entry| OpenStruct.build_recursive(entry) }
             else
               return source
           end
  end
end