class DateHelper
  def self.safe_parse(value, default = nil)
    DateTime.parse(value.to_s)
  rescue ArgumentError
    default
  end
end
