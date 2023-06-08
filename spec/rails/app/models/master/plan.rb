module Master
  class Plan < ApplicationRecord
    self.table_name = "master_plans"

    include ChoronSupport::DomainDelegate
    # method: #register
    #   To: Domains::Master::Plans::Register(app/models/domains/master/plans/register.rb#call)
    domain_delegate :register
  end
end