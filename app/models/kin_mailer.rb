class KinMailer < ActionMailer::Base
  def invitation
    
  end
  def message_to_collaborator (user, collaborator, subject_text, body_text)
    recipients collaborator.email
    from  user.email
    subject subject_text
    body :body_text=>body_text
  end 
end
