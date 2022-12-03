module Users
  class Form < ChoronSupport::Forms::Base
    def create
      :create
    end

    def update
      :update
    end
  end
end