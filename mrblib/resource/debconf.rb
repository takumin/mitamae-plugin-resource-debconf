module ::MItamae
  module Plugin
    module Resource
      class Debconf < ::MItamae::Resource::Base
        define_attribute :name, type: String, default_name: true
        define_attribute :question, type: String
        define_attribute :unseen, type: [TrueClass, FalseClass]
        define_attribute :value, type: String
        define_attribute :vtype, type: String

        self.available_actions = [:present, :absent]
      end
    end
  end
end
