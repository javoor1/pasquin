class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :omniauthable, :omniauth_providers => [:facebook]
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  after_initialize :set_defaults

  ##Database Associations
  has_many :posts
  has_many :comments

  ##Validations

 
   validates_presence_of :first_name, :last_name  #, :unless =>  :from_omniauth? 
   validates_length_of :first_name, :last_name, :minimum => 1, :maximum => 30 #, :unless =>  :from_omniauth? 


  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end

  def self.from_omniauth(auth)
    puts 'inside from_omniauth'
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.first_name = auth.info.first_name
      user.last_name = auth.info.last_name   # assuming the user model has a name
      user.image = auth.info.image # assuming the user model has an image
    end
  end

  private

  #  def from_omniauth?
  #   provider && uid 
  # end 


  def set_defaults
    self.type ||= 'User'
  end
end

