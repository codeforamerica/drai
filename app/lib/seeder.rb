class Seeder
  def self.seed
    new.seed
  end

  def seed
    admin_user
  end

  private

  def admin_user
    @admin_user ||= User.create email: 'admin@dafi.org', password: 'qwerty', confirmed_at: Time.current
  end
end
