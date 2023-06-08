# as_props のテスト用Modelです
class PropsComment < ApplicationRecord
  include ChoronSupport::AsProps

  belongs_to :user
end