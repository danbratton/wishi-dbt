# Summary
* I developed a data model following dimensional modeling techiques (also known as a star schema) for app activity data from [wishi](https://www.getwishi.com), a wish list web application.
* I used **dbt** to build the cental [`fact_events`](https://danbratton.github.io/wishi-dbt/#!/model/model.wishi.fact_events). table where each row represents a single user-generated event that took place in [wishi](https://www.getwishi.com).
* I also used **dbt** to build several dimensional tables that can be joined with `fact_events` to get more information about users, lists, items on a list, or the events themselves.
* The dbt auto-generated docs [here](https://danbratton.github.io/wishi-dbt) have details about the models I developed.
* I visualized the data in [**Looker Studio**](https://lookerstudio.google.com/reporting/b5c35fcb-9d47-48e8-af6f-e75dd61164da).

# Goals
I want to be able to monitor key metrics for my web app, [wishi](https://www.getwishi.com), such as:
* Daily/Monthly active users
* Monthly new account creations
* Use activation rate 

I also want to monitor product metrics such as:
* The average number of lists users have
* The average number of items on a list
* What portion of list items are URLs
* How many lists are viewed by anonymous users (because it was shared)

To do this, I needed to develop a data pipeline to transform raw event data and product data from [wishi](https://www.getwishi.com) into analytics-ready data that can be visualized in a dashboard.

# Developing the data model
I followed Kimball's dimensional modeling techniques when deciding how to model the data from [wishi](https://www.getwishi.com).

### **Step 1**: The business process

The key business process for [wishi](https://www.getwishi.com) is when a user uses the web app to create a new account, create a list, add items to a list, share a list, etc. I call this an **event** or **user action**.

### **Step 2**: The grain

The grain is a single user action in the web app. This is the *atomic* grain, which will set my data model up to handle pretty much any future analytic questions. 

An example alternative would be to declare the grain as a day's user activity. This would mean all activity for a day would be pre-aggregated into columns such as total new accounts created for the day and total user actions for the day. However, this would limit the downstream analysis that could be performed. For instance, I wouldn't be able to know which user performed which actions. This would prevent me from slicing across user types, for example, which is important for comparing groups of users (such as power users vs. casual users) or cohort analysis.

The atomic grain I have selected gives analysts the flexibility to calculate daily aggregations (like the above) and also any other analysis on user activity.

### Step 3: The dimensions
The dimension will describe more context about the central business process (a user action). The dimensions I have selected are:
* **Users**: This will describe a user such as the date of the last action they took, when they created their account, and what method they used to create an account(email, sign up with Google, etc.).
* **Lists**: This will describe a list with details such as who owns the list, when the list was created, when the list was last updated, whether the list is private, and more.
* **Items on a list**: This will describe an item on a list such as whether or not it has a priority, a comment, a URL, and/or has been marked as purchased.
* **Event details**: For example, when a new user signs up for an account the dimension table for that event will include data such as the source of the user (Google search, marketing campaign, etc.) and their sign up method (email, sign up with Google, etc.)
* **Dates**: This will contain helpful information about dates such as whether it is a holiday and what day of the week the date falls on.

### Step 4: The fact
The fact is a single user action. Some of the actions tracked are:
| Event name           | Event description                                                                                   |
|----------------------|-----------------------------------------------------------------------------------------------------|
| USER_SIGNED_UP       | A user created a new account                                                                        |
| USER_SIGNED_IN       | A user signed into an existing account                                                              |
| CREATED_LIST         | An authenticated user creates a new list                                                            |
| VIEWED_LISTS         | An authenticated user views their list of lists                                                     |
| VIEWED_LIST          | An authenticated user viewed a list.                                                                |
| UPDATED_LIST         | An authenticated user updates an existing list. This could be the name, comment, or sharing settings. |
| DELETED_LIST         | An authenticated user deleted an existing list.                                                     |
| ADDED_LIST_ITEM      | An authenticated user adds an item to an existing list.                                             |
| UPDATED_LIST_ITEM    | An authenticated user updates an existing item on a list. This could include the item name, item url, quantity, comment, or priority. |
| DELETED_LIST_ITEM    | An authenticated user deletes an existing item from a list                                          |

### The fact table
* Details about the `fact_events` table is in the auto-generated docs from dbt [here](https://danbratton.github.io/wishi-dbt/#!/model/model.wishi.fact_events).
* I decided to include information that is present for **most** events. There are cases where some columns will be `NULL`. For example, when an anonymous user views a list there will not be a `user_id`.

| Column Name       | Description                            | Example |
|-------------------|----------------------------------------|-- |
| event_id          | Primary key <br> `NUMBER(10,0)`<br>NOT Nullable                                      | 220 |
| event_key         | Foreign key to the `dim_events` table <br> `NUMBER(10,0)`<br>NOT Nullable                                      | 7 |
| event_name        | The name of the event <br>`VARCHAR(255)`<br>NOT Nullable                            | VIEWED_LIST |
| user_key          | Foreign key to the `dim_users` table <br> `NUMBER(10,0)`<br>Nullable                                      | 381|
| session_id        | The id from the user's session <br> `VARCHAR(255)`<br>Nullable       | xnvzi8l0pldjdmr23c1cycoq1c7m7wwm |
| list_key          | Foreign key to the `dim_lists` table <br> `NUMBER(10,0)`<br>Nullable | 8 |
| list_item_key     | Foreign key to the `dim_items` table <br> `NUMBER(10,0)`<br>Nullable | 766 |
| event_timestamp   | The timezoned timestamp of the event<br>`DATETIME`<br>NOT Nullable  | 2025-04-25 13:03:47.752 -0400|
| date_key          | A foreign, natural key to the `dim_dates` table<br> `VARCHAR(8,0)`|20250425 |

# Keeping the data fresh
In order to keep the data models updated I created a [github action](https://github.com/danbratton/wishi-dbt/blob/main/.github/workflows/dbt-build-schedule.yml). This action triggers a deployment of the `wishi-dbt` repo to Digital Ocean. I've set up this deployment to run `dbt build` in the [Dockerfile](https://github.com/danbratton/wishi-dbt/blob/main/wishi/Dockerfile).
