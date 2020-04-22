class Seeder
  def self.seed
    new.seed
  end

  def seed
    admin_user
    organization
    assister
    aid_application
  end

  private

  def admin_user
    @admin_user ||= User.find_or_create_by!(email: 'admin@dafi.org') { |user| user.attributes = { name: "Admin Adminface", password: 'qwerty', admin: true, confirmed_at: Time.current } }
  end

  def organization
    @organization ||= Organization.find_or_create_by!(name: 'Food Bank')
  end

  def assister
    @assister ||= User.find_or_create_by!(email: 'assister@foodbank.org') { |user| user.attributes = { name: 'Assister Assisterface', organization: organization, password: 'qwerty', admin: false, confirmed_at: Time.current } }
  end

  def aid_application
    FactoryBot.create :aid_application, assister: assister, organization: organization
  end
end
