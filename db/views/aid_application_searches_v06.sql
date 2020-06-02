SELECT
    aid_applications.id AS aid_application_id,
    (
        aid_applications.id || ' ' ||
        aid_applications.application_number || ' ' ||
        replace(aid_applications.application_number, 'APP-', '') || ' ' ||
        regexp_replace(aid_applications.application_number, '[^0-9]', '', 'g') || ' ' ||
        coalesce(aid_applications.name, '') || ' ' ||
        (CASE WHEN aid_applications.birthday IS NOT NULL THEN to_char(aid_applications.birthday, 'MM/DD/YYYY') ELSE '' END) || ' ' ||
        (CASE WHEN aid_applications.birthday IS NOT NULL THEN to_char(aid_applications.birthday, 'FMMM/FMDD/YYYY') ELSE '' END) || ' ' ||
        coalesce(aid_applications.street_address, '') || ' ' ||
        coalesce(aid_applications.city, '') || ' ' ||
        coalesce(aid_applications.zip_code, '') || ' ' ||
        coalesce(aid_applications.email, '') || ' ' ||
        coalesce(aid_applications.phone_number, '') || ' ' ||
        coalesce(payment_cards.sequence_number, '')
    ) AS searchable_data
FROM aid_applications
LEFT JOIN payment_cards ON payment_cards.aid_application_id = aid_applications.id
WHERE aid_applications.application_number IS NOT NULL


