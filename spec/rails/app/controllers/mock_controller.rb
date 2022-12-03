class MockController
  attr_reader :controller_path, :current_user, :params

  include ChoronSupport::BuildForm

  def initialize(controller_path, current_user, params)
    @controller_path = controller_path
    @current_user = current_user
    @params = params
  end
end