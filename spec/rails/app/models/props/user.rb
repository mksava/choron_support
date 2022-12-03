module Props
  class User < ChoronSupport::Props::Base
    def as_props
      {
        id: model.id,
        name: model.name,
        email: model.email
      }
    end
  end
end