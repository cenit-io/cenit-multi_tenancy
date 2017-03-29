require 'mongo/database/view'
require 'mongo/operation/commands/list_collections'

module Mongo

  class Database

    class View

      attr_reader :collections_filter

      alias_method :mongo_collections_names, :collection_names

      def collection_names(options = {})
        @collections_filter = options.reject { |key, _| key == :batch_size }
        mongo_collections_names
      end

      private

      def collections_info_spec
        {
          selector: {
            listCollections: 1,
            cursor: batch_size ? { batchSize: batch_size } : {},
            filter: collections_filter || {},
          },
          db_name: @database.name
        }
      end
    end
  end

  module Operation

    class ListCollections

      private

      def selector
        selector = spec[SELECTOR] || {}
        selector[:listCollections] = 1
        filter = { name: { '$not' => /system\.|\$/ } }
        if selector.key?(:filter)
          filter = { '$and' => [selector[:filter], filter] }
        end
        selector[:filter] = filter
        selector
      end
    end
  end
end
