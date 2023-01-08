module Props
  module Master
    class Plan < ChoronSupport::Props::Base
      def as_props
        model
          .as_json(
            only: %i[
              id
              name
            ]
          )
          .as_camel
      end
    end
  end
end