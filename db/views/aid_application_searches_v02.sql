with
-- one column per member
member_details as (
    select
        m.aid_application_id,
        (
            coalesce(m.name, '')
        ) as info
    from members m
),
-- one row for all members of an application
combined_member_details as (
    SELECT
        aid_application_id,
        string_agg(member_details.info::text, ' ') AS info
    FROM member_details
    GROUP BY aid_application_id
)
select
    aid_applications.id as aid_application_id,
    (
        aid_applications.id || ' ' ||
        coalesce(combined_member_details.info, '') || ' ' ||
        coalesce(aid_applications.street_address, '') || ' ' ||
        coalesce(aid_applications.city, '') || ' ' ||
        coalesce(aid_applications.zip_code, '') || ' ' ||
        coalesce(aid_applications.email, '') || ' ' ||
        coalesce(aid_applications.phone_number, '')
    ) as searchable_data
from aid_applications
left join combined_member_details on aid_applications.id = combined_member_details.aid_application_id
