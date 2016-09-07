module Cenit
  module MultiTenancy
    module Scoped
      extend ActiveSupport::Concern

      included do
        store_in collection: -> { Cenit::MultiTenancy.tenant_model.tenant_collection_name(to_s) }
      end

      module ClassMethods

        def mongoid_root_class
          @mongoid_root_class ||=
            begin
              root = self
              root = root.superclass while root.superclass.include?(Mongoid::Document)
              root
            end
        end

        def with(options)
          if ((tenant = options).is_a?(Cenit::MultiTenancy.tenant_model) && (options = {})) ||
            (options.is_a?(Hash) && options.has_key?(Cenit::MultiTenancy.tenant_model_key) && ((tenant = options.delete(Cenit::MultiTenancy.tenant_model_key)) || true))
            options = options.merge(collection: Cenit::MultiTenancy.tenant_model.tenant_collection_name(mongoid_root_class, Cenit::MultiTenancy.tenant_model_key => tenant))
          end
          super
        end
      end
    end
  end
end