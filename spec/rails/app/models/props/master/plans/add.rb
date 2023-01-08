
module Props
  module Master
    module Plans
      class Add < ChoronSupport::Props::Base
        def as_props
          model
            .as_json(
              only: %i[
                id
                name
              ]
            )
            .merge(
              addSpec: "hello",
            )
            .as_camel
        end
      end
    end
  end
end
