class MaskingUser < ApplicationRecord
  include ChoronSupport::SetMaskFor
  set_mask_for :name, :is_super_man, :weight, :height, :birth_date
end