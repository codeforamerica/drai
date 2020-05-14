select
    aid_applications.id as aid_application_id,
    (
        aid_applications.id || ' ' ||
        coalesce(aid_applications.name, '') || ' ' ||
        coalesce(aid_applications.street_address, '') || ' ' ||
        coalesce(aid_applications.city, '') || ' ' ||
        coalesce(aid_applications.zip_code, '') || ' ' ||
        coalesce(aid_applications.email, '') || ' ' ||
        coalesce(aid_applications.phone_number, '') ||
        coalesce(aid_applications.application_number, '')
    ) as searchable_data
from aid_applications
