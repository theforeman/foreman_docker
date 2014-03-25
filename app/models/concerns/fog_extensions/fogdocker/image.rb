module FogExtensions
  module Fogdocker
    module Image
      extend ActiveSupport::Concern

      include ActionView::Helpers::NumberHelper

      def name
        repo_tags.empty? ? (repository || id) : repo_tags.first
      end

    end
  end
end