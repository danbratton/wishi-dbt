with distinct_events as (
	select distinct event_name 
    from {{ source('public', 'wishlist_rawevents') }}
)

select 
	row_number() over (order by de.event_name) as id,
	de.event_name,
    ed.event_description
from distinct_events de
left join {{ ref('event_descriptions') }} ed on de.event_name = ed.event_name