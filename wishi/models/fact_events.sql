select
    re.id as event_id,
    dim_events.id as event_key,
    re.event_name,
    user_id as user_key,
    session_id,
    (event_details->>'list_id')::int as list_key,
    (event_details->>'item_id')::int as list_item_key,    
    event_timestamp,
    TO_CHAR(event_timestamp::timestamptz, 'YYYYMMDD')::varchar(8) AS date_key
from {{ source('public', 'wishlist_rawevents') }} re
left join {{ ref('event_descriptions')}} ed on re.event_name = ed.event_name
left join {{ ref('dim_events') }} dim_events on dim_events.event_name = re.event_name