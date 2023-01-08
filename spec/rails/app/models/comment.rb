class Comment < ApplicationRecord
  include ChoronSupport::AsProps

  belongs_to :user
end