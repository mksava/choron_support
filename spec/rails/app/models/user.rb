class User < ApplicationRecord
  has_many :comments

  include ChoronSupport::ScopeQuery
  # method: .limit_to
  #   To: Queries::LimitTo(app/models/queries/limit_to.rb#call)
  scope_query :limit_to, specific: false
  # method: .by_name
  #   To: Queries::Users::ByName(app/models/queries/users/by_name.rb#call)
  scope_query :by_name
  # method: .email_to
  #   To: Queries::Users::ByName(app/models/queries/users/by_email.rb#call)
  scope_query :email_to, class_name: "Queries::Users::ByEmail"

  include ChoronSupport::DomainDelegate
  # method: #register
  #   To: Domains::Users::Register(app/models/domains/users/register.rb#call)
  domain_delegate :register
  # method: #clear_to
  #   To: Domains::Users::Clear(app/models/domains/users/clear.rb#call)
  domain_delegate :clear_to, class_name: "Domains::Users::Clear"
  # method: #purchase
  #   To: Domains::Users::Purchase(app/models/domains/users/clear.rb#run)
  domain_delegate :purchase, to: :run
  # method: #hit
  #   To: Domains::Hit(app/models/domains/hit.rb#call)
  domain_delegate :hit, specific: false

  include ChoronSupport::AsProps
end