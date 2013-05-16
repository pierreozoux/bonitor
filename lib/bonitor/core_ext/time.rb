require "date"

class Time
  def hours_ago
    ((Time.now - self)/3600).ceil
  end

  def minutes_ago
    ((Time.now - self)/60).ceil
  end

  def seconds_ago
    (Time.now - self).ceil
  end

  def prettier
    if self.to_date == Date.today
      day_ref = ""
    elsif self.to_date == Date.today.prev_day
      day_ref = "Yesterday at"
    elsif (self.to_date > Date.today - 7) && (self.to_date < Date.today.prev_day)
      day_ref = "#{self.strftime("%A")} at"
    else
      day_ref = "#{self.strftime("%d %m")} at"
    end

    "#{day_ref} #{self.strftime("%H:%M")}"
  end

end
