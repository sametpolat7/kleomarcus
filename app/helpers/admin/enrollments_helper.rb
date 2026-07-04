module Admin::EnrollmentsHelper
  ENROLLMENT_STATUS_VARIANTS = {
    "received" => :info,
    "called" => :warning,
    "positive" => :success,
    "negative" => :error,
    "undecided" => :neutral
  }.freeze

  def enrollment_status_label(enrollment)
    badge(Enrollment.enum_label(:statuses, enrollment.status), variant: ENROLLMENT_STATUS_VARIANTS[enrollment.status])
  end

  def enrollment_level_label(enrollment)
    badge(Enrollment.enum_label(:levels, enrollment.level), variant: :ghost)
  end

  def format_phone(value)
    digits = value.to_s.delete("^0-9")
    digits = "0#{digits.delete_prefix("90")}" if digits.length == 12 && digits.start_with?("90")
    digits = "0#{digits}" if digits.length == 10
    return value.to_s unless digits.length == 11

    [ digits[0, 4], digits[4, 3], digits[7, 2], digits[9, 2] ].join(" ")
  end
end
