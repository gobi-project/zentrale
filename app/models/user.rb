class User < ActiveRecord::Base
  attr_accessor :password

  has_many :session_token, dependent: :destroy
  EMAIL_REGEX = /\A[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,6}\Z/i

  validates :username, presence: true, uniqueness: true, length: { in: 3..20 }
  validates :email, presence: true, uniqueness: true, format: EMAIL_REGEX
  validates :password, presence: true, on: :create
  validates :password, length: { minimum: 6  }, if: :password

  before_save :encrypt_password
  after_save :clear_password

  def self.authenticate(username_or_email = '', login_password = '')
    ActiveRecord::Base.connection_pool.with_connection do
      if EMAIL_REGEX =~ username_or_email
        user = User.find_by_email(username_or_email)
      else
        user = User.find_by_username(username_or_email)
      end

      if user && user.match_password(login_password)
        user
      else
        false
      end
    end
  end

  def match_password(login_password = '')
    encrypted_password == BCrypt::Engine.hash_secret(login_password, salt)
  end

  private

  def encrypt_password
    if password.present?
      self.salt = BCrypt::Engine.generate_salt
      self.encrypted_password = BCrypt::Engine.hash_secret(password, salt)
    end
  end

  def clear_password
    self.password = nil
  end
end
