class String
	def / (string)
		File.join(self, string)
	end
end

def accessor (*names)
	names.each do |name|
		instance_name = "@#{name}"
		class_eval "def #{name} (value = nil)
			value.nil? ? instance_variable_get('#{instance_name}') : instance_variable_set('#{instance_name}', value)
		end"
	end
end

module SpecificationDsl
	accessor :name, :summary, :version, :files, :build
	
	# def initialize
	# 	@build = :dsss
	# end
end

class SpecificationEnviroment
	#instance_methods.each { |meth| undef_method(meth) unless meth =~ /\A__/ }
	
	include SpecificationDsl
	
	def get_binding
		binding
	end	
end