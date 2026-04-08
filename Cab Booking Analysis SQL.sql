create database cb;
use cb;

create table customers (
 customerid int primary key,
 name varchar(100),
 email varchar(100),
 registrationdate date
);

insert into customers (customerid, name, email, registrationdate) values
(1, 'alice johnson', 'alice@example.com', '2023-01-15'),
(2, 'bob smith', 'bob@example.com', '2023-02-20'),
(3, 'charlie brown', 'charlie@example.com', '2023-03-05'),
(4, 'diana prince', 'diana@example.com', '2023-04-10');

create table drivers (
 driverid int primary key,
 name varchar(100),
 joindate date
);

insert into drivers (driverid, name, joindate) values
(101, 'john driver', '2022-05-10'),
(102, 'linda miles', '2022-07-25'),
(103, 'kevin road', '2023-01-01'),
(104, 'sandra swift', '2022-11-11');

create table cabs (
 cabid int primary key,
 driverid int,
 vehicletype varchar(20),
 platenumber varchar(20),
 foreign key (driverid) references drivers(driverid)
);

insert into cabs (cabid, driverid, vehicletype, platenumber) values
(1001, 101, 'sedan', 'abc1234'),
(1002, 102, 'suv', 'xyz5678'),
(1003, 103, 'sedan', 'lmn8901'),
(1004, 104, 'suv', 'pqr3456');

create table bookings (
 bookingid int primary key,
 customerid int,
 cabid int,
 bookingdate datetime,
 status varchar(20),
 pickuplocation varchar(100),
 dropofflocation varchar(100),
 foreign key (customerid) references customers(customerid),
 foreign key (cabid) references cabs(cabid)
);

insert into bookings (bookingid, customerid, cabid, bookingdate,
status, pickuplocation, dropofflocation) values
(201, 1, 1001, '2024-10-01 08:30:00', 'completed', 'downtown',
'airport'),
(202, 2, 1002, '2024-10-02 09:00:00', 'completed', 'mall',
'university'),
(203, 3, 1003, '2024-10-03 10:15:00', 'canceled', 'station',
'downtown'),
(204, 4, 1004, '2024-10-04 14:00:00', 'completed', 'suburbs',
'downtown'),
(205, 1, 1002, '2024-10-05 18:45:00', 'completed', 'downtown',
'airport'),
(206, 2, 1001, '2024-10-06 07:20:00', 'canceled', 'university',
'mall');

create table tripdetails (
 tripid int primary key,
 bookingid int,
 starttime datetime,
 endtime datetime,
 distancekm float,
 fare float,
 foreign key (bookingid) references bookings(bookingid)
);

insert into tripdetails (tripid, bookingid, starttime, endtime,
distancekm, fare) values
(301, 201, '2024-10-01 08:45:00', '2024-10-01 09:20:00', 18.5,
250.00),
(302, 202, '2024-10-02 09:10:00', '2024-10-02 09:40:00', 12.0,
180.00),
(303, 204, '2024-10-04 14:10:00', '2024-10-04 14:40:00', 10.0,
150.00),
(304, 205, '2024-10-05 18:50:00', '2024-10-05 19:30:00', 20.0,
270.00);

create table feedback (
 feedbackid int primary key,
 bookingid int,
 rating float,
 comments text,
 feedbackdate date,
 foreign key (bookingid) references bookings(bookingid)
);

insert into feedback (feedbackid, bookingid, rating, comments,
feedbackdate) values
(401, 201, 4.5, 'smooth ride', '2024-10-01'),
(402, 202, 3.0, 'driver was late', '2024-10-02'),
(403, 204, 5.0, 'excellent service', '2024-10-04'),
(404, 205, 2.5, 'cab was not clean', '2024-10-05');

select * from customers;
select * from drivers;
select * from cabs;
select * from bookings;
select * from tripdetails;
select * from feedback;

use  cb;


/* Problem Statement:

Customer and Booking Analysis

1. Identify customers who have completed the most bookings. What insights can you
draw about their behavior? */

select c.customerid, c.name, count(b.bookingid) as completed_bookings
from customers c
join bookings b on c.customerid = b.customerid
where b.status = 'completed'
group by c.customerid, c.name
order by completed_bookings desc;

-- These customers use the service a lot and seem loyal.

/* 2. Find customers who have canceled more than 30% of their total bookings. What
could be the reason for frequent cancellations? */


select 
    c.customerid,
    c.name,
    sum(b.status = 'canceled') * 100.0 / count(*) as cancel_rate
from customers c
join bookings b on c.customerid = b.customerid
group by c.customerid, c.name
having sum(b.status = 'canceled') * 100.0 / count(*) > 30;




-- These customers may face timing issues or change plans often.

/* 3. Determine the busiest day of the week for bookings. How can the company optimize
cab availability on peak days? */

select dayname(bookingdate) as day, count(*) as total_bookings
from bookings
group by day
order by total_bookings desc;

-- Peak days need more cabs to reduce waiting times.

/* Driver Performance & Efficiency

1. Identify drivers who have received an average rating below 3.0 in the past three
months. What strategies can be implemented to improve their performance?*/ 

select d.driverid, d.name, avg(f.rating) as avg_rating
from drivers d
join cabs c on d.driverid = c.driverid
join bookings b on c.cabid = b.cabid
join feedback f on b.bookingid = f.bookingid
group by d.driverid, d.name
having avg_rating < 3;

-- Low-rated drivers may need training or monitoring.

/*2. Find the top 5 drivers who have completed the longest trips in terms of distance.
What does this say about their working patterns? */

select d.driverid, d.name, sum(t.distancekm) as total_distance
from drivers d
join cabs c on d.driverid = c.driverid
join bookings b on c.cabid = b.cabid
join tripdetails t on b.bookingid = t.bookingid
group by d.driverid, d.name
order by total_distance desc
limit 5;

-- Top drivers handle longer trips, possibly working longer hours.

/* 3. Identify drivers with a high percentage of canceled trips. Could this indicate driver
unreliability? */

select d.driverid, d.name,
count(case when b.status = 'canceled' then 1 end) * 100.0 / count(*) as cancel_rate
from drivers d
join cabs c on d.driverid = c.driverid
join bookings b on c.cabid = b.cabid
group by d.driverid, d.name
having cancel_rate > 30;

 -- Drivers canceling often could be unreliable or overbooked.
 
/* Revenue & Business Metrics

1. Calculate the total revenue generated by completed bookings in the last 6 months.
How has the revenue trend changed over time? */

select sum(t.fare) as total_revenue
from tripdetails t
join bookings b on t.bookingid = b.bookingid
where b.status = 'completed';

-- Shows overall income; trend analysis helps in planning promotions.

/* 2. Identify the top 3 most frequently traveled routes based on PickupLocation and
DropoffLocation. Should the company allocate more cabs to these routes? */ 

select pickuplocation, dropofflocation, count(*) as total_trips
from bookings
where status = 'completed'
group by pickuplocation, dropofflocation
order by total_trips desc
limit 3;

-- Frequent routes may need more cabs to meet demand. 

/* 3. Determine if higher-rated drivers tend to complete more trips and earn higher fares.
Is there a direct correlation between driver ratings and earnings? */ 

select d.name, avg(f.rating) as avg_rating, sum(t.fare) as total_earnings
from drivers d
join cabs c on d.driverid = c.driverid
join bookings b on c.cabid = b.cabid
join tripdetails t on b.bookingid = t.bookingid
join feedback f on b.bookingid = f.bookingid
group by d.name
order by avg_rating desc;

-- Higher-rated drivers often earn more; good service attracts more trips.

/* Operational Efficiency & Optimization

1. Analyze the average waiting time (difference between booking time and trip start
time) for different pickup locations. How can this be optimized to reduce delays? */ 

select b.pickuplocation,
avg(timestampdiff(minute, b.bookingdate, t.starttime)) as avg_wait_time
from bookings b
join tripdetails t on b.bookingid = t.bookingid
group by b.pickuplocation;

 -- Longer waits at some locations; can optimize driver allocation.

/* 2. Identify the most common reasons for trip cancellations from customer feedback.
What actions can be taken to reduce cancellations? */ 

select comments, count(*) as occurrences
from feedback
group by comments
order by occurrences desc;

 -- Common issues like no-show or delay can be addressed to reduce cancellations.
 

/* 3. Find out whether shorter trips (low-distance) contribute significantly to revenue.
Should the company encourage more short-distance rides? */ 

select sum(fare) as short_trip_revenue
from tripdetails
where distancekm < 10;

 -- Short trips earn less but contribute steadily; consider promoting them.
 

/* Comparative & Predictive Analysis

1. Compare the revenue generated from 'Sedan' and 'SUV' cabs. Should the company
invest more in a particular vehicle type?*/ 

select c.vehicletype, sum(t.fare) as total_revenue
from cabs c
join bookings b on c.cabid = b.cabid
join tripdetails t on b.bookingid = t.bookingid
group by c.vehicletype;

 -- Compare vehicle types; invest more in higher-revenue types.

/* 2. Predict which customers are likely to stop using the service based on their last
booking date and frequency of rides. How can customer retention be improved? */

select c.vehicletype, sum(t.fare) as revenue
from cabs c
join bookings b on c.cabid = b.cabid
join tripdetails t on b.bookingid = t.bookingid
where b.status = 'completed'
group by c.vehicletype;

-- customers who haven’t booked in a long time and ride less often are more likely to leave 
-- and retention can be improved through discounts, reminders, better service, and loyalty rewards.


/* 3. Analyze whether weekend bookings differ significantly from weekday bookings.
Should the company introduce dynamic pricing based on demand? */  

select
case
when dayofweek(bookingdate) in (1,7) then 'weekend'
else 'weekday'
end as day_type,
count(*) as total_bookings
from bookings
group by day_type;

-- Demand differs; dynamic pricing can balance supply and demand.



