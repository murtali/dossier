class EmployeeReport < Dossier::Report

  set_callback :build_query, :before, :example_before_hook
  set_callback :execute,     :after  do
    # do some stuff
  end

  # Valid for users to choose via a multi-select
  def self.valid_columns
    %w[id name hired_on suspended]
  end

  def query
    "SELECT #{columns} FROM employees WHERE 1=1".tap do |sql|
      sql << " AND divisions in (:divisions)" if divisions.any?
      sql << " AND salary > :salary"          if salary?
      sql << " AND (#{names_like})"           if names_like.present?
      sql << " ORDER BY name #{order}"
    end
  end

  def columns
    valid_columns.join(', ').presence || '*'
  end

  def valid_columns
    self.class.valid_columns & Array.wrap(options[:columns])
  end

  def order
    options[:order].to_s.upcase === 'DESC' ? 'DESC' : 'ASC'
  end

  def salary
    10_000
  end

  def name
    "%#{names.pop}%"
  end

  def divisions
    @divisions ||= options.fetch(:divisions) { [] }
  end

  def salary?
    options[:salary].present?
  end

  def names_like
    names.map { |name| "name like :name" }.join(' or ')
  end

  def names
    @names ||= options.fetch(:names) { [] }.dup
  end

  def format_salary(amount)
    formatter.currency(amount) unless format.csv?
  end

  def format_hired_on(date)
    formatter.date(date)
  end

  def format_name(name)
    "Employee #{value}"
  end

  def example_before_hook
    # do some stuff
  end

end
