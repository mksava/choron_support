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
  # method: #clear_hello
  #   To: Domains::Users::Clear(app/models/domains/users/clear.rb#call)
  domain_delegate :clear_hello, class_name: :clear, to: :hello
  # method: #clear_spec1
  #   To: Domains::Users::Clear(app/models/domains/users/clear.rb#call)
  domain_delegate :clear_spec1, class_name: :clear, to: :spec1
  # method: #clear_spec2
  #   To: Domains::Users::Clear(app/models/domains/users/clear.rb#call)
  domain_delegate :clear_spec2, class_name: :clear, to: :spec2
  # method: #purchase
  #   To: Domains::Users::Purchase(app/models/domains/users/clear.rb#run)
  domain_delegate :purchase, to: :run
  # method: #hit
  #   To: Domains::Hit(app/models/domains/hit.rb#call)
  domain_delegate :hit, specific: false

  # method: .fire
  #   To: Domains::Users::Fire(app/models/domains/users/fire.rb#call)
  class_domain_delegate :fire
  # method: .import_csv
  #   To: Domains::Users::ImportCsv(app/models/domains/users/import_csv.rb#call)
  class_domain_delegate :import_csv
  # method: .age_create
  #   To: Domains::Users::AgeManage(app/models/domains/users/age_manage.rb#create)
  class_domain_delegate :age_create, class_name: :age_manage, to: :create
  # method: .age_destroy
  #   To: Domains::Users::AgeManage(app/models/domains/users/age_manage.rb#destroy)
  class_domain_delegate :age_destroy, class_name: :age_manage, to: :destroy

  include ChoronSupport::AsProps

  # Delegateをオーバーライドしているため
  delegate delegate_foo: :delegate_obj
  def delegate_obj
    Struct.new(:delegate_foo).new("call delegate_foo")
  end
end