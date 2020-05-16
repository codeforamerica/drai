SELECT
    aid_applications.id AS aid_application_id,
    (
        aid_applications.id || ' ' ||
        coalesce(aid_applications.name, '') || ' ' ||
        coalesce(aid_applications.street_address, '') || ' ' ||
        coalesce(aid_applications.city, '') || ' ' ||
        coalesce(aid_applications.zip_code, '') || ' ' ||
        coalesce(aid_applications.email, '') || ' ' ||
        coalesce(aid_applications.phone_number, '') || ' ' ||
        coalesce(aid_applications.application_number, '')
    ) AS searchable_data
FROM aid_applications
WHERE aid_applications.application_number IS NOT NULL


