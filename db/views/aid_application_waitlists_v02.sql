WITH positions AS (
    SELECT
        aid_applications.id AS aid_application_id,
        aid_applications.organization_id,
        aid_applications.county_name,
        (ROW_NUMBER() OVER (PARTITION BY organization_id ORDER BY aid_applications.id ASC)) - organizations.total_payment_cards_count AS waitlist_position
    FROM aid_applications
    JOIN organizations ON organizations.id = aid_applications.organization_id
    WHERE
        aid_applications.rejected_at IS NULL
        AND aid_applications.paused_at IS NULL
)

SELECT * FROM positions WHERE waitlist_position > 0
