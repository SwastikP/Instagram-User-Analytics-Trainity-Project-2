/* Rewarding Most Loyal Users: People who have been using the platform for the longest time.
Your Task: Find the 5 oldest users of the Instagram from the database provided*/
use ig_clone;


select * from users 
order by created_at asc 
limit 5;

/*Remind Inactive Users to Start Posting: By sending them promotional emails to post their 1st photo.
Your Task: Find the users who have never posted a single photo on Instagram*/

(select * from users where id not in
(select distinct user_id from photos))

/*Declaring Contest Winner: The team started a contest and the user who gets the most likes on a single photo will win 
the contest now they wish to declare the winner.
Your Task: Identify the winner of the contest and provide their details to the team */

#with cte approach
with cte1 as 
(select photo_id,count(*) as total_likes
from likes 
group by photo_id 
order by 2 desc 
limit 1),
cte2 as
(select * 
from photos p 
join cte1 c 
on p.id=c.photo_id )
select user_id,photo_id,image_url,total_likes from cte2

#Another Way

select u.username,p.id,p.image_url,COUNT(*) AS total_likes
from photos p  
join likes l
on l.photo_id = p.id
join users u
on p.user_id = u.id
group by p.id
order by 4 desc
limit 1;

/* Hashtag Researching: A partner brand wants to know, which hashtags to use in the post to reach the most people on the platform.
Your Task: Identify and suggest the top 5 most commonly used hashtags on the platform */
select t.id,t.tag_name,count(*) as tag_count
from tags t 
inner join photo_tags pt 
on t.id=pt.tag_id
group by t.id 
order by 3 desc
limit 5

#Another Way

with cte1 as(
select tag_id,count(*) as tag_count 
from photo_tags 
group by tag_id
order by 2 desc
limit 5)
select tag_id,tag_name,tag_count 
from tags t inner join cte1 c
on t.id=c.tag_id

/*Launch AD Campaign: The team wants to know, which day would be the best day to launch ADs.
Your Task: What day of the week do most users register on? Provide insights on when to schedule an ad campaign */
/*
select dayname(created_at),count(*) from users
group by dayname(created_at) 
order by 2 desc 
*/
#more generic approach

with cte1 as(select dayname(created_at) as day_name,count(*) as tc
from users group by dayname(created_at) order by 2 desc),
cte2 as (select day_name,tc,dense_rank() over(order by tc desc) as 'rn1' from cte1 ) 
select * from cte2 where rn1=1


/*User Engagement: Are users still as active and post on Instagram or they are making fewer posts
Your Task: Provide how many times does average user posts on Instagram. Also, provide the total 
number of photos on Instagram/total number of users*/

select distinct p.user_id,count(p.id)
from users u
inner join photos p
on u.id=p.user_id
group by p.user_id


with cte1 as (SELECT count(*) as total_photos FROM   photos),
cte2 as (SELECT count(*) as total_users FROM   users)
select cte1.total_photos/cte2.total_users as avg_post_per_user from cte1 inner join cte2


/*Bots & Fake Accounts: The investors want to know if the platform is crowded with fake and dummy accounts
Your Task: Provide data on users (bots) who have liked every single photo on the site (since any normal user would not be able to do this).*/

with cte1 as
(
select count(*) as max_possible_like_by_bot from photos),
cte2 as
(select u.id,u.username, count(*) AS num_likes 
from users u
inner join likes l
on u.id =l.user_id 
group by l.user_id)
select * from cte2 
join cte1
where cte2.num_likes=cte1.max_possible_like_by_bot


