require 'cenit/multi_tenancy/version'
require 'cenit/multi_tenancy/scoped'
require 'cenit/multi_tenancy/user_scope'
require 'request_store'
require 'cenit/multi_tenancy/mongo_monkey_patch'

module Cenit
  module MultiTenancy
    extend ActiveSupport::Concern

    class << self
      include Config

      def default_options
        {
          tenant_model_key: -> { @tenant_model_key ||= tenant_model_name.split('::').last.underscore.to_sym },
          tenant_model_id_key: -> { @tenant_model_id_key ||= "#{tenant_model_key}_id".to_sym },
          collection_prefix: -> { @collection_prefix ||= tenant_model_key.to_s[0..2] }
        }
      end

      %w(tenant user).each do |key|
        class_eval "def #{key}_model(*args)
          if (model = args[0]).is_a?(Class)
            options[:#{key}_model] = model
            #{key}_model_name model.to_s
          end
          options[:#{key}_model]
        end"
      end

      def current_tenant
        tenant_model.current
      end

      def current_tenant=(tenant)
        tenant_model.current = tenant
      end
    end

    included do
      Cenit::MultiTenancy.tenant_model self
    end

    def tenant_collections_names
      self.class.tenant_collections_names(self)
    end

    def each_tenant_collection(&block)
      self.class.each_tenant_collection(self, &block)
    end

    def switch(&block)
      current = Cenit::MultiTenancy.current_tenant
      Cenit::MultiTenancy.current_tenant = self
      block.call if block
    ensure
      Cenit::MultiTenancy.current_tenant = current if block
    end

    module ClassMethods

      def current
        RequestStore.store["current_#{Cenit::MultiTenancy.tenant_model_key}".to_sym]
      end

      def current=(tenant)
        RequestStore.store["current_#{Cenit::MultiTenancy.tenant_model_key}".to_sym] = tenant
      end

      def current_tenant
        current
      end

      def tenant_collection_prefix(options = {})
        sep = options[:separator] || ''
        tenant_id =
          if (tenant = options[:tenant] || options[Cenit::MultiTenancy.tenant_model_key])
            tenant.id
          else
            options[:tenant_id] || options[Cenit::MultiTenancy.tenant_model_id_key] ||
              ([
                :tenant,
                :tenant_id,
                Cenit::MultiTenancy.tenant_model_key,
                Cenit::MultiTenancy.tenant_model_id_key
              ].none? { |key| options.has_key?(key) } && (tenant = current_tenant) && tenant.id)
          end
        tenant_id ? "#{Cenit::MultiTenancy.collection_prefix}#{tenant_id}#{sep}" : ''
      end

      def tenant_collection_name(model_name, options = {})
        model_name = model_name.to_s
        options[:separator] ||= '_'
        tenant_collection_prefix(options) + model_name.collectionize
      end

      def tenant_collections_names(tenant = current)
        regex = Regexp.new("\\A#{tenant_collection_prefix(tenant: tenant)}(_|\.)[^$]+\\Z")
        Mongoid.default_client.database.collection_names(
          name: regex, # TODO Remove when stop legacy support
          filter: { name: regex }
        )
      end

      def each_tenant_collection(tenant = current, &block)
        tenant_collections_names(tenant).each do |collection_name|
          block.call(Mongoid.default_client[collection_name.to_sym])
        end
      end
    end

  end
end
