require 'cenit/multi_tenancy/version'
require 'cenit/multi_tenancy/scoped'
require 'cenit/multi_tenancy/user_scope'
require 'request_store'

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
    end

    included do
      Cenit::MultiTenancy.tenant_model self
    end

    def cenit_collections_names
      self.class.cenit_collections_names(self)
    end

    def each_cenit_collection(&block)
      self.class.each_cenit_collection(self, &block)
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

      def cenit_collections_names(tenant = current)
        db_name = Mongoid.default_client.database.name
        Mongoid.default_client[:'system.namespaces']
          .find(name: Regexp.new("\\A#{db_name}\.#{tenant_collection_prefix(tenant: tenant)}_[^$]+\\Z"))
          .collect { |doc| doc['name'] }
          .collect { |name| name.gsub(Regexp.new("\\A#{db_name}\."), '') }
      end

      def each_cenit_collection(tenant = current, &block)
        cenit_collections_names(tenant).each do |collection_name|
          block.call(Mongoid.default_client[collection_name.to_sym])
        end
      end
    end

  end
end
