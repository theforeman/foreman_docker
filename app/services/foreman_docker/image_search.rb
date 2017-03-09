module ForemanDocker
  class ImageSearch
    def initialize(*args)
      @sources = {}
      args.each do |source|
        add_source(source)
      end
    end

    def add_source(source)
      case source
      when ForemanDocker::Docker
        @sources[:compute_resource] ||= []
        @sources[:compute_resource] << source
      when Service::RegistryApi
        @sources[:registry] ||= []
        @sources[:registry] << source
      end
    end

    def remove_source(source)
      @sources.each do |_, sources|
        sources.delete(source)
      end
    end

    def search(query)
      return [] if query[:term].blank? || query[:term] == ':'

      unless query[:tags] == 'true'
        images(query[:term])
      else
        tags(query[:term])
      end
    end

    def images(query)
      sources_results_for(:search, query)
    end

    def tags(query)
      image_name, tag = query.split(':')
      sources_results_for(:tags, image_name, tag)
        .map { |tag_name| { 'name' => tag_name } }
    end

    def available?(query)
      tags(query).present?
    end

    private

    def registry_search(registry, term)
      registry.search(term)['results']
    end

    def compute_resource_search(compute_resource, query)
      images = compute_resource.local_images(query)
      images.flat_map do |image|
        image.info['RepoTags'].map do |tag|
          { 'name' => tag.split(':').first }
        end
      end.uniq
    end

    def compute_resource_image(compute_resource, image_name)
      compute_resource.image(image_name)
    rescue ::Docker::Error::NotFoundError
      nil
    end

    def compute_resource_tags(compute_resource, image_name, tag)
      image = compute_resource_image(compute_resource, image_name)
      image ? compute_resource.tags_for_local_image(image, tag) : []
    end

    def registry_tags(registry, image_name, tag)
      registry.tags(image_name, tag).map { |t| t['name'] }
    end

    def sources_results_for(search, *args)
      result = []
      @sources.each do |kind, sources|
        sources.each do |source|
          result << self.send("#{kind}_#{search}", source, *args)
        end
      end
      result.flatten.compact
    end
  end
end

