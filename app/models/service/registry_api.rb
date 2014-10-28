module Service
  class RegistryApi
    DEFAULTS = { :url => 'http://localhost:5000' }
    attr_reader :config

    def initialize(params = {})
      @config = DEFAULTS.merge(params)
    end

    def search(aquery)
      response = RestClient.get(config[:url] + '/v1/search',
                                :params => { :q => aquery }, :accept => :json)
      JSON.parse(response.body)
    end

    def list_repository_tags(arepository)
      response = RestClient.get(config[:url] + "/v1/repositories/#{arepository}/tags",
                                :accept => :json)
      JSON.parse(response.body)
    end
  end
end
