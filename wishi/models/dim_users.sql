with last_action as (
	select
		user_key, 
        max(event_timestamp) as last_action
	from {{ ref('fact_events') }} fe 
	where user_key is not null
	group by user_key
)

select
	user_id as id,
	sign_up_method,
	created_at,
	updated_at,
	last_action
from {{ source('public', 'wishlist_userprofile') }} wu
left join last_action la on la.user_key = wu.user_id