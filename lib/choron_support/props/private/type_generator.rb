# @deprecated
class ChoronSupport::Props::Private::TypeGenerator
  def run
    start_output

    results = []
    targer_props.each do |props_class|
      result = builder_class.new(props_class).generate
      results << result
    end

    output_results(results)

    results
  end

  private

  def target_props_class?(props_class)
    props_class.respond_to?(:skip_typescript) && props_class.respond_to?(:settings)
  end

  def self.props_base
    Props::Base
  end

  def targer_props
    props_list = []
    self.class.props_base.descendants.each do |props_class|
      next unless target_props_class?(props_class)
      next if props_class.skip_typescript

      props_list << props_class
    end

    props_list
  end

  def builder_class
    ChoronSupport::Props::Private::TypeBuilder
  end

  def start_output
    log("Start generating TypeScript Props...: #{targer_props.size}")
  end

  def output_results(results)
    log("Generated TypeScript Props: #{results.size}")
    log("for...")
    results.each do |result|
      log("  #{result.file_path}")
    end

    log("Done.")
  end

  def log(str)
    @logger_method ||= defined?(Rails) ? Rails.logger.method(:info) : method(:puts)

    @logger_method.call(str)
  end
end
