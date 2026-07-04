class EnrollmentMailer < ApplicationMailer
  def new_application(enrollment)
    @enrollment = enrollment

    mail to: notification_email, subject: "Yeni #{@enrollment.discipline.name} Başvurusu — #{@enrollment.full_name}"
  end

  private

  # Recipient is configurable without a deploy: credentials first, then ENV, then a safe fallback.
  def notification_email
    Rails.application.credentials.dig(:enrollment, :notification_email) ||
      ENV.fetch("ENROLLMENT_NOTIFICATION_EMAIL", "info@kleomarcus.com")
  end
end
