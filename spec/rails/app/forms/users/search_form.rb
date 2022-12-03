module Users
  class SearchForm < ChoronSupport::Forms::Base
    def search
      User.where(name: params[:name])
    end
  end
end