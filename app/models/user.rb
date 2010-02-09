class User < ActiveRecord::Base
  require 'digest/sha1'
  #one to one
  belongs_to :profile
  
  #one to many
  has_many :messages, :dependent=>:destroy
  has_many :activities, :dependent=>:destroy
  has_many :revisions #revision more strongly belongs to a project..
  
  #many to many through
  has_many :managed_projects, :dependent=>:destroy
  has_many :projects, :through => :managed_projects
  
  #self-referential many to many
  has_and_belongs_to_many :collaborators, :class_name => "User", :join_table => "collaborators", :foreign_key => "user_id", :association_foreign_key => "collaborator_id"
  
  #validation
  validates_presence_of   :email
  validates_uniqueness_of :email
  validates_confirmation_of :password 
  validate  :password_non_blank
  
  attr_accessor :password_confirmation
  
  def password
    @password
  end
  
  def password=(pwd)
    @password = pwd
    return if pwd.blank?
    create_new_salt
    self.hashed_password = User.encrypted_password(self.password, self.salt)
  end
  def self.authenticate (email, password)
    user = self.find_by_email(email)
    if user
      expected_password = encrypted_password(password, user.salt)
      if (user.hashed_password != expected_password)
        user = nil
      end
    end
    user
  end
  
private
  def password_non_blank
    errors.add(:password, "Missing password") if hashed_password.blank?
  end
  def self.encrypted_password(password, salt)
    string_to_hash = password + "wibble" + salt
    Digest::SHA1.hexdigest(string_to_hash)
  end
  
  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end
end
