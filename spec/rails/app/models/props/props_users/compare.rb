module Props
  module PropsUsers
    class Compare < ChoronSupport::Props::Base
      def as_props(comment: "hello")
        { user_id: model.id, compare_spec: "compare", comment: comment }
      end
    end
  end
end
