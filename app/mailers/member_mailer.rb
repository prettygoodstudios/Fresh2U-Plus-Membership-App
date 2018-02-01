class MemberMailer < ApplicationMailer
  default from: "miguel@prettygoodstudios.com"
  def welcome_email(member)
    @member = Member.find(member)
    mail(:to => @member.email, :subject => "Welcome to Fresh2U Plus!")
  end
end
