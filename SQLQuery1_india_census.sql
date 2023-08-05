select * from project_1.dbo.Dataset1;

select * from Dataset1
where state in ('Jharkhand', 'Bihar')

--total population
select sum(Population) as total_population from Dataset2

-- average growth
select State,avg(Growth)*100 as average from project_1.dbo.Dataset1
group by State

-- average sex ratio
select State,round(avg(Sex_Ratio),0) as average from project_1.dbo.Dataset1
group by State order by average desc;

-- average literacy ratio
-- average literacy above 90
select State,round(avg(Literacy),0) as average_literacy from project_1.dbo.Dataset1
group by State having round(avg(Literacy),0) > 90 order by average_literacy desc;


-- it will display the top 3 states having the highest growth rate
select top 3 State, avg(Growth)*100 average_growth from project_1.dbo.Dataset1
group by State order by average_growth desc;

-- to display the bottom 4 states with lowest growth rate
select top 4 State, avg(Growth)*100 average_growth from project_1.dbo.Dataset1
group by State order by average_growth asc;

drop table if exists refined_table_1
create table refined_table_1
(State nvarchar(255), top_avg_literacy float)

insert into refined_table_1
select State, avg(Literacy) average from project_1.dbo.Dataset1
group by State order by average desc;

select * from refined_table_1

drop table if exists refined_table_bottom
create table refined_table_bottom
( 
	State nvarchar(255), top_avg_literacy float)

insert into refined_table_bottom
select State, avg(Literacy) average from project_1.dbo.Dataset1
group by State order by average asc;

-- joining two tables to see the top 3 states having highest literacy and the bottom 3 literacy states

select * from 
(select top 3 * from refined_table_1
order by top_avg_literacy desc ) a

union 

select * from 
(select top 3 * from refined_table_bottom
order by top_avg_literacy asc) b


-- to find the states starting with "a"

select * from project_1.dbo.Dataset1 
where lower(State) like 'a%'

-- to find the states starting with "a" and ending with "m"
select * from project_1.dbo.Dataset1
where lower(State) like 'a%' and lower(State) like '%m';


-- Both the tables are joined using inner join

select * from project_1.dbo.Dataset2
select a.District, a.State, a.Sex_Ratio, b.Population from project_1.dbo.Dataset1 a inner join project_1.dbo.Dataset2 b
on a.District=b.District

delete from project_1.dbo.Dataset1
where Literacy is NULL


-- total male and female in every state

select g.State, sum(g.males) total_males, sum(g.females) total_females from(
select v.State,round(v.Population/(1 + v.Sex_Ratio),0) males, round((v.Sex_Ratio* v.Population)/(v.Sex_Ratio+1),0) females 
from (
select a.District, a.State, a.Sex_Ratio/1000 Sex_Ratio, b.Population from project_1.dbo.Dataset1 a inner join project_1.dbo.Dataset2 b
on a.District=b.District) v)g
group by g.State;


-- total literate and illiterate people in every state

select f.State, sum(f.literate_people) total_literate, sum(f.total_illiterate) total_illiterate_ppl from (
select c.District, c.State, round(c.Literacy_Ratio*c.Population ,0) literate_people, round((c.Population)*(1 - c.literacy_Ratio),0) total_illiterate from 
(select a.District, a.State, (a.Literacy/1000) literacy_Ratio, b.Population Population from project_1.dbo.Dataset1 a inner join project_1.dbo.Dataset2 b
on a.District=b.District) c )f
group by f.State

-- to check the population in previous census
-- comparing previous census to the current one

select e.state, sum(e.previous_census) Previous_census, sum(e.current_census) current_census from(
select l.State, round(l.Population/(1+l.growth),0) previous_census, l.Population current_census from
(select a.State, a.Growth growth, b.Population Population from project_1.dbo.Dataset1 a inner join project_1.dbo.Dataset2 b
on a.District=b.District)l)e
group by e.State


-- to find the top 2 districts from every state(window functions)
select * from (
select District, State, 
RANK() over(partition by State order by Literacy desc) ranking 
from project_1.dbo.Dataset1) m
where m.ranking <3

select * from project_1.dbo.Dataset1