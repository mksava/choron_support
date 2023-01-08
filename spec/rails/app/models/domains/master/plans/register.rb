module Domains
  module Master
    module Plans
      class Register < ChoronSupport::Domains::Base
        def call
          "#{master_plan.id}だよ"
        end
      end
    end
  end
end