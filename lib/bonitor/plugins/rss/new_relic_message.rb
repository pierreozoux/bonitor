require_relative "../../core_ext/time.rb"

class NewRelicMessage
  attr_reader :severity
  attr_reader :message
  attr_reader :pretty_date

  def initialize(item)
    @severity = item.title.match(/(?<=\[)[^]]+(?=\])/)
    @message = item.title.match(/(?<=- ).*/)
    @pretty_date = item.pubDate.prettier
  end

  def to_s
    "[#{@severity}] #{@pretty_date}: #{@message}"
  end
end
