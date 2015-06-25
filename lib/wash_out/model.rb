module WashOut
  module Model
    def wash_out_columns
      columns_hash
    end

    def wash_out_param_map
      types = {
        :text      => :string,
        :float     => :double,
        :decimal   => :double,
        :timestamp => :string,
        :ntext     => :string
      }
      map = {}

      wash_out_columns.each do |key, column|
        type = column.type
        type = types[type] if types.has_key?(type)
        map[key] = type
      end

      map
    end

    def wash_out_param_name(*args)
      return name.camelize if args[0].camelize_wsdl == true
      return name.underscore
    end
  end
end