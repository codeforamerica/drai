class Seeder
  def self.seed
    new.seed
  end

  def seed
    admin_user
    organization
    supervisor
    assister
    FactoryBot.create_list :aid_application, 5, :disbursed, creator: assister, organization: organization
    FactoryBot.create_list :aid_application, 10, :approved, creator: assister, organization: organization
    FactoryBot.create_list :aid_application, 50, :submitted, creator: assister, organization: organization
    FactoryBot.create_list :aid_application, 5, creator: assister, organization: organization

    %w[
      123456
      223456
      323456
      423456
      523456
      623456
    ].each do |sequence_number|
      next if PaymentCard.find_by(sequence_number: sequence_number)
      FactoryBot.create(:payment_card, sequence_number: sequence_number)
    end

    refresh_search_views
  end

  private

  def admin_user
    @admin_user ||= User.find_or_create_by!(email: 'admin@codeforamerica.org') do |user|
      user.assign_attributes(
        name: "Admin Awesome",
        password: 'Qwerty!2',
        admin: true,
        confirmed_at: Time.current
      )
    end
  end

  def organization
    @organization ||= Organization.find_or_create_by!(name: 'Legal Aid') do |organization|
      organization.assign_attributes(
        total_payment_cards_count: 10000,
        county_names: ["San Francisco", "San Mateo"]
      )
    end
  end

  def assister
    @assister ||= User.find_or_create_by!(email: 'assister@aid.org') do |user|
      user.assign_attributes(
        name: 'Assister Thankful',
        organization: organization,
        password: 'Qwerty!2',
        confirmed_at: Time.current
      )
    end
  end

  def supervisor
    @supervisor ||= User.find_or_create_by!(email: 'supervisor@aid.org') do |user|
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
