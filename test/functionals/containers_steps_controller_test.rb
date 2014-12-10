require 'test_plugin_helper'

module Containers
  class StepsControllerTest < ActionController::TestCase
    setup do
      @container = FactoryGirl.create(:container)
    end

    test 'wizard finishes with a redirect to the managed container' do
      state = DockerContainerWizardState.create!
      Service::Containers.expects(:start_container!).with(equals(state)).returns(@container)
      put :update, { :wizard_state_id => state.id,
                     :id => :environment,
                     :docker_container_wizard_states_environment => { :tty => false } },
          set_session_user

      assert_redirected_to container_path(:id => @container.id)
    end
  end
end
