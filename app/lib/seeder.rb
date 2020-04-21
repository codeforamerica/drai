class Seeder
  def self.seed
    new.seed
  end

  def seed
    admin_user
    organization
    assister
  end

  private

  def admin_user
    @admin_user ||= User.create name: "Admin Adminface", email: 'admin@dafi.org', password: 'qwerty', confirmed_at: Time.current
  end

  def organization
    @organization ||= Organization.create name: 'Food Bank'
  end

  def assister
    @assister ||= User.create name: 'Assister Assisterface', email: 'assister@foodbank.org', organization: organization, password: 'qwerty', confirmed_at: Time.current
  end
end
