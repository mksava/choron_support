# frozen_string_literal: true

puts "Load gem files..."
require "active_record"
require "mysql2"
require "pry-rails"
require "pry-byebug"
require "yaml"
require "factory_bot_rails"
require 'rspec-parameterized'

# simplecovでコードカバレッジを集計する
require 'simplecov'
# TODO この begin~rescue~endの対応は時期を見て削除する
# Github workflow 環境で以下のエラーが発生するためrescueでキャッチさせて無視しています
# RuntimeError:
#   coverage measurement is already setup
# ./spec/rails_helper.rb:10:in `<top (required)>'
# ローカルでは起きていないためキャッシュなどが悪さをしている可能性があります
begin
  SimpleCov.start
rescue => e
  puts e
end

puts "Load files..."

require "choron_support"
require_relative "rails/config/initializers/choron"

Dir[File.join(__dir__, 'rails/**/*.rb')].each {|file| require file }
Dir[File.join(__dir__, 'factories/**/*.rb')].each {|file| require file }

puts "Start RSpec configure..."
RSpec.configure do |config|
  # FactoryBotのメソッドを名前空間なしで使えるようにする
  config.include FactoryBot::Syntax::Methods

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.before(:each) do
    User.delete_all
    Comment.delete_all
  end

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

db_settings = YAML.load_file("spec/rails/config/database.yml")

# DB作成。必要なときは以下をtrueに変更してください
db_create = false
if db_create
  puts "Start DB create..."
  client_settings = db_settings.dup
  client_settings["database"] = nil
  client = Mysql2::Client.new(client_settings)

  client.query("CREATE DATABASE IF NOT EXISTS #{db_settings["database"]}")
end

# テーブル作成。必要なときは以下をtrueに変更してください
table_create = false
if table_create
  puts "Start DB Table create..."
  system("make spec-table-create")
end

# DB接続設定
puts "Setting ActiveRecord"
ActiveRecord::Base.establish_connection(db_settings)

if ENV["CONSOLE"] == "true"
  binding.pry
  puts "end"
  exit 1
end