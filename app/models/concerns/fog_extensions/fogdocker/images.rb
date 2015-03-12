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

      def downcase_hash_keys(hash, k = [])
        if hash.is_a?(Hash)
          return hash.reduce({}) { |a, e| a.merge! downcase_hash_keys(e[-1], k + [e[0]]) }
        end
        { k.join('_').gsub(/([a-z])([A-Z])/, '\1_\2').downcase => hash }
      end
    end
  end
end
