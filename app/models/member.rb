# == Schema Information
#
# Table name: members
#
#  id                 :bigint           not null, primary key
#  birthday           :date
#  name               :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  aid_application_id :bigint
#
# Indexes
#
#  index_members_on_aid_application_id  (aid_application_id)
#
# Foreign Keys
#
#  fk_rails_...  (aid_application_id => aid_applications.id)
#
class Member < ApplicationRecord
  belongs_to :aid_application, counter_cache: true

  with_options on: :submit_aid_application do
    validates :name, presence: true
    validates :birthday, presence: true, inclusion: {in: -> (_member) {'01/01/1900'.to_date..18.years.ago}, message: 'Must be 18-years or older and born after 1900'}
  end

  scope :find_duplicates, (lambda do |member|
    includes(:aid_application)
        .references(:aid_application)
        .where.not(id: member.id)
        .where(name: member.name, birthday: member.birthday, aid_applications: {zip_code: member.aid_application.zip_code})
  end)

  def find_duplicates
    self.class.find_duplicates(self)
  end
end
