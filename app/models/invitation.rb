class Invitation < ActiveRecord::Base
  belongs_to  :sender, :class_name=>"User"
  belongs_to  :project
  has_one      :recipient, :class_name=>"User"
  
  validates_presence_of :recipient_email
  validate  :recipient_is_not_registered
  
  before_create :generate_token

  def recipient_is_not_registered
    errors.add :recipient_email, 'is already registered' if User.find_by_email(recipient_email)
  end 
  def generate_token
    self.token = Digest::SHA1.hexdigest([Time.now, rand].join)
  end  
end
