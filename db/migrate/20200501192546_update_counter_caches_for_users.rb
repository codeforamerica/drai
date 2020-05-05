class UpdateCounterCachesForUsers < ActiveRecord::Migration[6.0]
  def change
    User.all.pluck(:id).each do |user_id|
      User.reset_counters(user_id, :aid_applications_created)
    end
  end
end
