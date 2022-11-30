class UserMailer < ApplicationMailer
  def welcome_email(email)
    validation_code = ValidationCode.order(created_at: :desc).find_by_email(email)
    p validation_code
    @code = validation_code.code
    mail(to: email, subject: '山竹记账验证码')
  end
end