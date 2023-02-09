# use first_database;
select * from covid_vaccination1;

-- total cases vs total deaths in united states
select location, date, total_cases, total_deaths, round((total_deaths / total_cases)*100, 2) as deathPercentage
from covid_death1
where location = 'United States'
order by 1, 2;


-- total cases vs population
select location, date, total_cases, population, round((total_cases/population)*100, 2) as infectedPercentage
from covid_death1
where location = 'United States'
order by 1, 2;

-- highest infection rate for each country
select location, population,
max(total_cases) as highest_infection_count, 
max(round((total_cases/population)*100, 2)) as highest_infection_rate
from covid_death1
where continent is not null
group by location, population
order by highest_infection_rate DESC;

-- highest death rate for each country
select location, population,
max(total_deaths) as highest_death_count, 
max(round((total_deaths/population)*100, 2)) as highest_death_rate
from covid_death1
where continent is not null and location not in ('Europe', 'North America', 'Asia', 'South America', 
'European Union', 'Lower middle income', 'High income', 'upper middle income', 'world')
group by location, population
order by highest_death_count DESC;


-- highest date rate for each continent
select continent,
max(total_deaths) as highest_death_count, 
max(round((total_deaths/population)*100, 2)) as highest_death_rate
from covid_death1
where continent is not null
group by continent
order by highest_death_count desc;


-- death rate all over the world over each day from jan 2020 to may 2022
select date, sum(new_cases) total_cases_distinct_date, sum(new_deaths) total_deaths_distinct_date, round(sum(new_deaths) / sum(new_cases)*100, 2) as death_rate
from covid_death1
where continent is not null
group by date
order by 1, 2;

-- total date rate over whole time span
select sum(new_cases) total_cases_distinct_date, sum(new_deaths) total_deaths_distinct_date, round(sum(new_deaths) / sum(new_cases)*100, 2) as death_rate
from covid_death1
where continent is not null
order by 1, 2;



-- work with covid-vaccination table

select * from covid_vaccination1;


-- joining two tables: 
-- total population vs total vaccination using partition by
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(v.new_vaccinations) over(partition by d.location order by d.location, d.date) as total_vaccination_till_day
from covid_death1 d
join covid_vaccination1 v
on v.location = d.location and v.date = d.date
where d.continent is not null
order by 2, 3;


-- using CTE find total population vs total_vaccinated
with CTE (continent, location, date, population, new_vaccinations, total_vaccinations_till_day)
as 
(select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(v.new_vaccinations) over(partition by d.location order by d.location, d.date) as total_vaccination_till_day
from covid_death1 d
join covid_vaccination1 v
on v.location = d.location and v.date = d.date
where d.continent is not null
order by 2, 3)

select *, (total_vaccinations_till_day / population)*100 as percentage_vaccinated_till_day from CTE;


-- vaccination rate using temp table
drop table if exists vaccination_rate;
Create table vaccination_rate
( continent nvarchar(255),
location nvarchar(255),
date date,
population int,
new_vaccinations int,
total_vaccinated_till_day double);

insert into vaccination_rate

select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(v.new_vaccinations) over(partition by d.location order by d.location, d.date) as total_vaccination_till_day
from covid_death1 d
join covid_vaccination1 v
on v.location = d.location and v.date = d.date
where d.continent is not null
order by 2, 3;

select *, (total_vaccinated_till_day / population)*100 as percentage_vaccinated_till_day from vaccination_rate;


-- creating view to use for data visualization in tableau
create view vaccination_rate_whole as

select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(v.new_vaccinations) over(partition by d.location order by d.location, d.date) as total_vaccination_till_day
from covid_death1 d
join covid_vaccination1 v
on v.location = d.location and v.date = d.date
where d.continent is not null
order by 2, 3;



