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
  accessor :summary, :version

  accessor :author, :build, :build_dependencies, :date, 
           :description, :dvm, :email, :executables,
            :homepage, :libraries, :name,
           :orbit_version, :platforms, :package_type,
           :runtime_dependencies, :specification_version,
           :type

  alias dependencies runtime_dependencies
  alias orbs runtime_dependencies

  def orb (name, version = nil)
    @runtime_dependencies << [name, version]
  end
  
  # Ugly workaround for a problem that seems related to
  # Ruby in combination with D and the Tango zip module
  def files (value = nil)
    value.nil? ? @files.join(",") : @files = value
  end
end

class SpecificationEnviroment
	#instance_methods.each { |meth| undef_method(meth) unless meth =~ /\A__/ }
	
	include SpecificationDsl
	
	def get_binding
		binding
	end	
end