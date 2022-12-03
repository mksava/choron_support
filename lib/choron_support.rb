# frozen_string_literal: true

module ChoronSupport
  SUPPORT_FILES = {
    domains: "choron_support/domain_delegate",
    queries: "choron_support/scope_query",
    forms: "choron_support/build_form",
    props: "choron_support/as_props",
  }
  private_constant :SUPPORT_FILES

  class Error < StandardError; end

  def self.using(*module_names)
    # 何かを使うのであれば共通で利用するもの
    require "active_support/all"
    require_relative "choron_support/version"
    require_relative "choron_support/helper"

    module_names.to_a.each do |module_name|
      case module_name.to_sym
      when :all
        SUPPORT_FILES.each do |key, file_name|
          require file_name
        end
      else
        file_name = SUPPORT_FILES[module_name.to_sym].to_s
        if file_name.empty?
          raise ArgumentError, "Not support #{module_name}, expected names: #{SUPPORT_FILES.keys} and :all"
        else
          require file_name
        end
      end
    end
  end
end
