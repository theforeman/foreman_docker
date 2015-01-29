class RegistriesController < ::ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  before_filter :find_registry, :only => [:edit, :update, :destroy]

  def index
    @registries = DockerRegistry.search_for(params[:search], :order => params[:order])
                  .paginate :page => params[:page]
  end

  def new
    @registry = DockerRegistry.new
  end

  def create
    @registry = DockerRegistry.new(params[:docker_registry])
    if @registry.save
      process_success
    else
      process_error
    end
  end

  def edit
  end

  def update
    if @registry.update_attributes(params[:docker_registry])
      process_success
    else
      process_error
    end
  end

  def destroy
    if @registry.destroy
      process_success
    else
      process_error
    end
  end

  def find_registry
    @registry = DockerRegistry.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    not_found
  end
end
