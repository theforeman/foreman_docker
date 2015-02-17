# Compatibility fixes - to be removed once 1.7 compatibility is no longer required
module FogExtensions
  module Fogdocker
    module Images
      extend ActiveSupport::Concern

      def image_search(query = {})
        Docker::Util.parse_json(Docker.connection.get('/images/search', query)).map do |image|
          downcase_hash_keys(image)
        end
      end
    end
  end
end
