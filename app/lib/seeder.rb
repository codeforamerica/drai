class Seeder
  def self.seed
    new.seed
  end

  def seed
    admin_user
    organization
    supervisor
    assister
    FactoryBot.create_list :aid_application, 2, :submitted, creator: assister, organization: organization
    FactoryBot.create_list :aid_application, 2, creator: assister, organization: organization

    refresh_search_views
  end

  private

  def admin_user
    @admin_user ||= User.find_or_create_by!(email: 'admin@dafi.org') do |user|
      user.assign_attributes(
        name: "Admin Awesome",
        password: 'Qwerty!2',
        admin: true,
        confirmed_at: Time.current
      )
    end
  end

  def organization
    @organization ||= Organization.find_or_create_by!(name: 'Food Bank') do |organization|
      organization.assign_attributes(
        total_payment_cards_count: 10
      )
    end
  end

  def assister
    @assister ||= User.find_or_create_by!(email: 'assister@foodbank.org') do |user|
      user.assign_attributes(
        name: 'Assister Thankful',
        organization: organization,
        password: 'Qwerty!2',
        confirmed_at: Time.current
      )
    end
  end

  def supervisor
    @supervisor ||= User.find_or_create_by!(email: 'supervisor@foodbank.org') do |user|
      user.assign_attributes(
        name: 'Supervisor Grateful',
        organization: organization,
        password: 'Qwerty!2',
        supervisor: true,
        confirmed_at: Time.current
      )
    end
  end

  def refresh_search_views
    AidApplicationSearch.refresh
  end
end
