class Seeder
  def self.seed
    new.seed
  end

  def seed
    admin_user
    organization
    supervisor
    assister
    FactoryBot.create_list :aid_application, 4, assister: assister, organization: organization
    refresh_search_views
  end

  private

  def admin_user
    @admin_user ||= User.find_or_create_by!(email: 'admin@dafi.org') do |user|
      user.attributes = {
        name: "Admin Awesome",
        password: 'qwerty',
        admin: true,
        confirmed_at: Time.current
      }
    end
  end

  def organization
    @organization ||= Organization.find_or_create_by!(name: 'Food Bank')
  end

  def assister
    @assister ||= User.find_or_create_by!(email: 'assister@foodbank.org') do |user|
      user.attributes = {
        name: 'Assister Thankful',
        organization: organization,
        password: 'qwerty',
        confirmed_at: Time.current
      }
    end
  end

  def supervisor
    @supervisor ||= User.find_or_create_by!(email: 'supervisor@foodbank.org') do |user|
      user.attributes = {
        name: 'Supervisor Grateful',
        organization: organization,
        password: 'qwerty',
        supervisor: true,
        confirmed_at: Time.current
      }
    end
  end

  def refresh_search_views
    AidApplicationSearch.refresh
  end
end
