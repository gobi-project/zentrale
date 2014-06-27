class SessionToken < ActiveRecord::Base
  before_create :generate_session_token
  belongs_to :user

  private

  def generate_session_token
    ActiveRecord::Base.connection_pool.with_connection do
      loop do
        self.token = SecureRandom.hex
        break unless SessionToken.find_by_token(token)
      end
    end
  end
end
