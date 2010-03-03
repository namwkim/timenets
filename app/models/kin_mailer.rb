class KinMailer < ActionMailer::Base

  def message_to_collaborator (user, collaborator, subject_text, body_text)
    recipients collaborator.email
    from  user.email
    subject subject_text
    body :body_text=>body_text
  end 
  def invitation(invitation, url)
    recipients  invitation.recipient_email
    from        invitation.sender.email
    subject     invitation.sender.person.name+" invited you to join "+invitation.project.name
    body :message=>invitation.message, :url=>url
    invitation.update_attribute(:sent_at, Time.now)
  end
end
