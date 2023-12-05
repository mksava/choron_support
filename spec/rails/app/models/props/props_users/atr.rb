module Props
  module PropsUsers
    class Atr < ChoronSupport::Props::Base
      include ChoronSupport::Props::Attributes
      attributes :id, :name
    end
  end
end
