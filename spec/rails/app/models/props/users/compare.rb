module Props
  module Users
    class Compare < ChoronSupport::Props::Base
      def as_props(camel: true)
        props = { user_id: model.id, compare_spec: "compare" }
        if camel
          props.as_camel
        else
          props
        end
      end
    end
  end
end