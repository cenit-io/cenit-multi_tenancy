module Cenit
  module MultiTenancy
    module Scoped
      extend ActiveSupport::Concern

      included do
        store_in collection: -> { Cenit::MultiTenancy.tenant_model.tenant_collection_name(collectionizable_name) }
      end

      module ClassMethods

        def collectionizable_name
          to_s
        end

        def mongoid_root_class
          @mongoid_root_class ||=
            begin
              root = self
              root = root.superclass while root.superclass.include?(Mongoid::Document)
              root
            end
        end
      end
    end
  end
end