module ForemanDocker
  module TaxonomyExtensions
    extend ActiveSupport::Concern

    included do
      if SETTINGS[:version].to_s.to_f <= 1.7
        def self.enabled_taxonomies
          %w(locations organizations).select { |taxonomy| SETTINGS["#{taxonomy}_enabled".to_sym] }
        end
      end
    end
  end
end
# To be removed after 1.7 compatibility is no longer required
