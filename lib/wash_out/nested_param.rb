module WashOut
	class NestedParam
		attr_reader :model, :includes
		def initialize(model,includes:[])
			@model = model
			@includes = includes
		end

		def name
			model.name
		end

		def to_param soap_config
			literal_attribute_hash = WashOut.model_to_definition_hash(model)
			nested_attribute_hash = Hash[
				includes.collect do |key,value|
					[
						key,
						WashOut::Param.new(soap_config,key,value)
					]
				end
			]
			all_attribute_hash = literal_attribute_hash.merge(nested_attribute_hash)
			{ model.name.to_sym => WashOut::Param.new(soap_config, model.name, all_attribute_hash)}
		end
	end
end