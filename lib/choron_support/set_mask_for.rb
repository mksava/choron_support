module ChoronSupport
  module SetMaskFor
    extend ActiveSupport::Concern

    class NameError < StandardError; end
    class CanNotMaskError < StandardError; end

    WITH_OUT_MASK_FLAG_VARIABLE_NAME = :__choron_with_out_mask_flag__
    MASKING_VALUES = { string: "****", else: nil }.freeze

    included do
      def self.set_mask_for(*method_symbols, condition: nil)
        method_symbols.each do |method_symbol|
          self.instance_eval { private attr_accessor WITH_OUT_MASK_FLAG_VARIABLE_NAME }
          define_method(method_symbol) do
            origin = super()

            # そもそも元の値がnilの場合はそのまま返し、validation等の妨げにならないようにしています
            return nil if origin.nil?

            type = :else
            case origin
            when String
              type = :string
            end

            if without_mask?
              origin
            else
              # 型によってマスクする値を変えています
              MASKING_VALUES[type]
            end
          end

          # マスクの値に関係なく元の値を取得するためのメソッドです。
          define_method("danger_without_mask_#{method_symbol}") do
            val = nil
            self.without_mask do |model|
              val = model.send(method_symbol)
            end
            val
          end
        end

        unless method_defined?(:danger_without_mask!)
          define_method(:danger_without_mask!) do
            send("#{WITH_OUT_MASK_FLAG_VARIABLE_NAME}=", true)

            self
          end
        end

        unless method_defined?(:without_mask)
          define_method(:without_mask) do |&block|
            self.danger_without_mask!
            block.call(self)
            self.wear_mask
          end
        end

        unless method_defined?(:wear_mask)
          define_method(:wear_mask) do
            send("#{WITH_OUT_MASK_FLAG_VARIABLE_NAME}=", false)

            self
          end
        end

        unless method_defined?(:without_mask?)
          define_method(:without_mask?) do
            !!send(WITH_OUT_MASK_FLAG_VARIABLE_NAME)
          end
        end
      end
    end
  end
end