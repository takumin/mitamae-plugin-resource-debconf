module ::MItamae
  module Plugin
    module Resource
      class Debconf < ::MItamae::Resource::Base
        define_attribute :action, default: :set
        define_attribute :package, type: String, default_name: true
        define_attribute :question, type: String, required: true
        define_attribute :vtype, type: String, required: true
        define_attribute :value, type: [String, Integer, FalseClass, TrueClass, Array], required: true

        self.available_actions = [:set, :reset]
      end
    end
  end
end
