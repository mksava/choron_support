# @deprecated
class ChoronSupport::Props::Private::TypeBuilder
  RESULT =  Struct.new(:file_path, :body, :type_name, :attributes)

  # @return [String]
  # @memo
  #   必要に応じてoverrideしてください
  def self.output_dir
    "app/javascript/types/props"
  end

  # @return [String]
  # @memo
  #   必要に応じてoverrideしてください
  def self.file_path(props_class)
    self.default_build_file_path(props_class)
  end

  def initialize(props_class)
    @body_buffer = []
    @attributes_buffer = []
    @props_class = props_class
  end

  # 設定値やクラス名からTypeScriptの型を生成する
  # @return [RESULT]
  # @example
  #   class Foo::Bars::Staff < Props::Base
  #     attribute :id, type: "number | null"
  #     attribute :name, type: "string"
  #     attribute :is_super, type: "boolean",
  #     attribute :license_names, type: "Array<string>"
  #   end
  #   builder = ChoronSupport::Props::Private::TypeBuilder.new(Foo::Bars::Staff)
  #   builder.build
  #   ####====#####
  #   type Foo_Bars_StaffProps = {
  #     id: number | null,
  #     name: string,
  #     is_super: boolean,
  #     license_names: Array<string>,
  #     type: "Foo::Bars::Staff"
  #     modelName: "Foo::Bar"
  #   }
  #   ####====#####
  def build
    set_type_buffer

    file_path = self.class.file_path(props_class)
    body = body_buffer.join("\n")
    type_name = build_type_name(props_class)
    attributes = attributes_buffer.join("\n")

    RESULT.new(file_path, body, type_name, attributes)
  end

  # buildされたTypeScriptの型をファイルに出力する
  # @return [RESULT]
  def generate
    result = self.build

    # 出力用のディレクトリがなければ作成する
    if !Dir.exist?(self.class.output_dir)
      FileUtils.mkdir_p(self.class.output_dir)
    end

    # ファイルを作成する
    File.open(result.file_path, "w") do |f|
      f.puts(result.body)
    end

    result
  end

  def __body_buffer__
    body_buffer
  end

  private

  attr_reader :props_class, :body_buffer, :attributes_buffer

  def self.default_build_file_path(props_class)
    # 分かりやすいようにそのままtypenameをファイル名にする
    file_name = props_class.name.gsub("::", "_") + ".d.ts"

    if defined?(Rails) && Rails.root.present?
      Rails.root.join(self.output_dir, file_name).to_s
    else
      File.join(self.output_dir, file_name)
    end
  end

  def set_type_buffer
    body_buffer << "type #{build_type_name(props_class)} = {"
    attributes_buffer = "{"

    build_attributes(props_class).each do |attr_val|
      body_buffer << "  #{attr_val}"
      attributes_buffer << "  #{attr_val}"
    end

    body_buffer << "}"
    attributes_buffer << "}"
  end

  def build_attributes(props_class)
    attributes = []
    props_class.settings.each do |setting|
      attributes << build_attribute(setting)
    end

    attributes
  end

  def build_attribute(setting)
    name = setting.name
    _if  = setting.if
    name_val = "#{name}#{_if ? "?" : ""}"

    type = setting.type

    "#{name_val}: #{type}"
  end

  def build_type_name(props_class)
    props_class.name.gsub("::", "_")
  end
end
