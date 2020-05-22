class AidApplicationCleaner
  def delete_stale_and_unsubmitted
    apps_to_delete = AidApplication.where(submitted_at: nil).where('created_at < ?', 1.day.ago)
    apps_to_delete.destroy_all
  end
end