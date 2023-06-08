# as_props のテスト用Modelです
class PropsUser < ApplicationRecord
  include ChoronSupport::AsProps

  has_many :props_comments, dependent: :destroy
end