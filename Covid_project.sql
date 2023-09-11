-- Data Exploration of Covid 19 Dataset in PostreSQL

-- Creating the tables. Just for the record, the file we extract the data to put in the tables is the same, I'm just splitting certain
-- columns to show more skills on SQL like JOINS, for example.

create table covid_deaths ();
create table covid_vaccinated();

-- Borramos columnas que no utilizaremos.
-- The main idea was to edit de CSV file and convert it to an axcel file and delete those columns where not gonnna be using. But as far 
-- as I'm concerned, we cannot import data from excel files in PostgreSQL so, I'm obligated to import the entire CSV file and delete the columns
-- manually.

alter table covid_deaths drop new_tests;
alter table covid_deaths drop total_tests_per_thousand;
alter table covid_deaths drop new_tests_per_thousand;
alter table covid_deaths drop new_tests_smoothed;
alter table covid_deaths drop new_tests_smoothed_per_thousand;
alter table covid_deaths drop positive_rate;
alter table covid_deaths drop tests_per_case;
alter table covid_deaths drop tests_units;
alter table covid_deaths drop total_vaccinations;
alter table covid_deaths drop people_vaccinated;
alter table covid_deaths drop people_fully_vaccinated;
alter table covid_deaths drop total_boosters;
alter table covid_deaths drop new_vaccinations;
alter table covid_deaths drop new_vaccinations_smoothed;
alter table covid_deaths drop total_vaccinations_per_hundred;
alter table covid_deaths drop people_vaccinated_per_hundred;
alter table covid_deaths drop people_fully_vaccinated_per_hundred;
alter table covid_deaths drop total_boosters_per_hundred;
alter table covid_deaths drop new_vaccinations_smoothed_per_million;
alter table covid_deaths drop new_people_vaccinated_smoothed;
alter table covid_deaths drop new_people_vaccinated_smoothed_per_hundred;
alter table covid_deaths drop stringency_index;
alter table covid_deaths drop population_density;
alter table covid_deaths drop median_age;
alter table covid_deaths drop aged_65_older;
alter table covid_deaths drop aged_70_older;
alter table covid_deaths drop gdp_per_capita;
alter table covid_deaths drop extreme_poverty;
alter table covid_deaths drop cardiovasc_death_rate;
alter table covid_deaths drop diabetes_prevalence;
alter table covid_deaths drop female_smokers;
alter table covid_deaths drop male_smokers;
alter table covid_deaths drop handwashing_facilities;
alter table covid_deaths drop hospital_beds_per_thousand;
alter table covid_deaths drop life_expectancy;
alter table covid_deaths drop human_development_index;
alter table covid_deaths drop excess_mortality_cumulative_absolute;
alter table covid_deaths drop excess_mortality_cumulative;
alter table covid_deaths drop excess_mortality;
alter table covid_deaths drop excess_mortality_cumulative_per_million;


alter table covid_vaccinated drop total_cases;
alter table covid_vaccinated drop new_cases;
alter table covid_vaccinated drop new_cases_smoothed;
alter table covid_vaccinated drop total_deaths;
alter table covid_vaccinated drop new_deaths;
alter table covid_vaccinated drop new_deaths_smoothed;
alter table covid_vaccinated drop total_cases_per_million;
alter table covid_vaccinated drop new_cases_per_million;
alter table covid_vaccinated drop new_cases_smoothed_per_million;
alter table covid_vaccinated drop total_deaths_per_million;
alter table covid_vaccinated drop new_deaths_per_million;
alter table covid_vaccinated drop new_deaths_smoothed_per_million;
alter table covid_vaccinated drop reproduction_rate;
alter table covid_vaccinated drop icu_patients;
alter table covid_vaccinated drop icu_patients_per_million;
alter table covid_vaccinated drop hosp_patients;
alter table covid_vaccinated drop hosp_patients_per_million;
alter table covid_vaccinated drop weekly_icu_admissions;
alter table covid_vaccinated drop weekly_icu_admissions_per_million;
alter table covid_vaccinated drop weekly_hosp_admissions;
alter table covid_vaccinated drop weekly_hosp_admissions_per_million;


-- Viendo las tablas completas:

select * from covid_deaths;
select * from covid_vaccinated;

-- Select data that we are going to be using:

select "location", "date", total_cases, new_cases, total_deaths, population
from covid_deaths
order by "location", "date";

-- Looking at total cases vs total deaths:

select
	location, 
	date,
	total_cases, 
	total_deaths, 
	(total_deaths)/(total_cases)*100 as deaths_per_case_percentage
from covid_deaths
order by 1,2;

-- Likelihood of dying if you contract covid in your country

select
	location, 
	date,
	total_cases, 
	total_deaths, 
	(total_deaths)/(total_cases)*100 as deaths_per_case_percentage
from covid_deaths
where location = 'Chile'
order by 1,2;

-- Looking at total cases vs population
-- What percentage of the population got covid?
select
	location, 
	date,
	total_cases, 
	population,
	(total_cases)/(population)*100 as cases_per_population_percentage
from covid_deaths
where location = 'Chile'
order by 1,2;

-- What countries have the highest infection rate compared to population?

select
	location,
	max(total_cases),
	max(population),
	max((total_cases/population))*100 as cases_per_population_percentage
from covid_deaths
group by location
having max((total_cases/population))*100 is not NULL
order by cases_per_population_percentage desc;

-- Showing countries with highest death count per population

select
	location,
	max(total_deaths),
	max(population),
	max((total_deaths/population)) as deaths_per_population
from covid_deaths
where continent != ''
group by location
having max((total_deaths/population))*100 is not null
-- order by max(total_deaths) desc;
order by deaths_per_population desc;


-- Showing continents with highest death count per population

select
	location,
	max(total_deaths),
	max(population),
	max((total_deaths/population)) as deaths_per_population
from covid_deaths
where continent = '' and location not in ('European Union', 'High income', 'Upper middle income', 'World', 'Lower middle income', 'Low income')
group by location
having max((total_deaths/population))*100 is not null
-- order by max(total_deaths) desc;
order by deaths_per_population desc;

-- Global numbers:
-- Veremos que en la primera query, obtenemos los casos acumulados en el día final ya que estamos agrupando por fecha (sum(total_cases)). Si
-- queremos saber el acumulado final, solo un valor, y no como varía por día, usamos la segunda query, en tal caso, no nos sirve utilzar
-- total_cases, ya que estaríamos sumando el total de cada día, que ya tiene incluidos los casos acumulados, por eso, debemos hacer sum(new_cases).
-- Pasa lo mismo con sum(total_deaths) en la query 1 y sum(new_deaths) en la query 2, son lo mismo.

select
	date, 
	sum(new_cases) as new_cases, 
	sum(total_cases) as acc_cases, 
	sum(new_deaths) as new_deaths, 
	sum(total_deaths) as acc_deaths,
	--sum(new_deaths)/sum(new_cases) as death_percetage,
	sum(total_deaths)/sum(total_cases)*100 as acc_death_percentage
from covid_deaths 
where continent != ''
group by date
order by 1;
	
select
	sum(new_cases) as acc_cases, 
	sum(new_deaths) as acc_deaths, 
	sum(new_deaths)/sum(new_cases)*100 as death_percetage
from covid_deaths 
where continent != ''
order by 1;

-- Intentamos hacer operaciones con la columna people_vaccinated y tratando de transformar los datos a float nos tira error, ya que los campos
-- '' no pueden ser transformados. Llegué a la conclusión de que podemos hacer operaciones de dos formas:
-- 1. Usando un CASE WHEN, así no modificamos la tabla y solo modificamos los datos para la query:
select 
	date, 
	location,
	case 
		when people_vaccinated = '' then 0
		when people_vaccinated != '' then people_vaccinated::float4
	end as para_sumar
	
from covid_vaccinated
where location = 'Chile'
order by location, date asc;

-- 2. Haciendo un UPDATE de los datos, reemplazando todos los espacios vacíos '' por 0:

update covid_vaccinated set people_vaccinated = 0 where people_vaccinated = '';
update covid_vaccinated set new_vaccinations = 0 where new_vaccinations  = '';

select people_vaccinated::float4
from covid_vaccinated
order by 1 asc;

-- Looking at total population vs vaccinations, ¿cuánta gente se ha vacunado a la fecha?

select 
	deaths.continent, 
	deaths.location, 
	deaths.date, 
	deaths.population,
	vaccinations.people_vaccinated::float4
from covid_deaths as deaths 
join covid_vaccinated as vaccinations
on deaths.location = vaccinations.location and 
deaths.date = vaccinations.date
where deaths.continent is not null and deaths.continent != ''
order by 2,3 asc;

select 
	deaths.continent, 
	deaths.location, 
	deaths.date, 
	deaths.population,
	vaccinations.new_vaccinations::float4,
	sum(vaccinations.new_vaccinations::float4) over (partition by deaths.location order by deaths.location, deaths.date) as vacc_acc
from covid_deaths as deaths 
join covid_vaccinated as vaccinations
on deaths.location = vaccinations.location and 
deaths.date = vaccinations.date
where deaths.continent is not null and deaths.continent != ''
order by 2,3 asc;

-- Junto con esto, quisiéramos obtener el porcentaje de la población vacunada por cada país, usando la columna new_vaccinations.
-- ¿Qué hacemos?

-- 1. Tabla temporal y usarla en una query
-- Usamos esta query solo para obtener el porcentaje final
with vaccines_accumulated as (
		select 
			deaths.location, 
			deaths.date,
			deaths.population,
			sum(vaccinations.new_vaccinations::float4) over (partition by deaths.location order by deaths.location, deaths.date) as vacc_acc
		from covid_deaths as deaths 
		join covid_vaccinated as vaccinations
		on deaths.location = vaccinations.location and 
		deaths.date = vaccinations.date
		where deaths.continent is not null and deaths.continent != ''
		order by 1,2 asc)
		
select 
	location,
	max(vacc_acc),
	max(vacc_acc/population)*100 as pctg_of_pp_vacc
from vaccines_accumulated
group by location
order by 1;
	

-- Usamos esta query cuando queremos actualizar el porcentaje a medida que pasa el tiempo

with vaccines_accumulated as (
		select 
			deaths.location, 
			deaths.date,
			deaths.population,
			sum(vaccinations.new_vaccinations::float4) over (partition by deaths.location order by deaths.location, deaths.date) as vacc_acc
		from covid_deaths as deaths 
		join covid_vaccinated as vaccinations
		on deaths.location = vaccinations.location and 
		deaths.date = vaccinations.date
		where deaths.continent is not null and deaths.continent != ''
		order by 1,2 asc)

select *, vacc_acc/population*100 as pctg_of_pp_vacc
from vaccines_accumulated
order by 1;

-- Creating views to store data for later visualizations

create view people_vaccinated as
select 
	deaths.location, 
	deaths.date,
	deaths.population,
	sum(vaccinations.new_vaccinations::float4) over (partition by deaths.location order by deaths.location, deaths.date) as vacc_acc
from covid_deaths as deaths 
join covid_vaccinated as vaccinations
on deaths.location = vaccinations.location and 
deaths.date = vaccinations.date
where deaths.continent is not null and deaths.continent != ''
order by 1,2 asc


/*

Queries used for Tableau Project

*/



-- 1. Get total covid cases, total deaths due to covid and the death percentage related to covid.

Select 
	SUM(new_cases) as total_cases, 
	SUM(cast(new_deaths as int)) as total_deaths, 
	trunc(cast(SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as numeric),2) as DeathPercentage
From covid_deaths
where continent != '' and location not in ('European Union', 'High income', 'Upper middle income', 'World', 'Lower middle income', 'Low income')
--Group By date
order by 1,2;


Select 
	SUM(new_cases) as total_cases, 
	SUM(cast(new_deaths as int)) as total_deaths, 
	case
		when sum(new_cases) != 0 then SUM(cast(new_deaths as int))/SUM(New_Cases)*100
		when sum(new_cases) = 0 then SUM(cast(new_deaths as int))*100
	end as death_percentage
From covid_deaths
Where location like '%States%'
--where location = 'World'
--Group By date
order by 1,2


-- 2. Total deaths due to covid

-- We take these out as they are not included in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From covid_deaths
--Where location like '%states%'
where continent = '' and location not in ('European Union', 'High income', 'Upper middle income', 'World', 'Lower middle income', 'Low income')
Group by location
order by TotalDeathCount desc


-- 3. Maximum amount of people who got covid and percetage of the population who got infected per country

Select 
	Location,
	Population,
	MAX(total_cases) as HighestInfectionCount, trunc(cast(Max((total_cases/population))*100 as numeric),2) as percentpopulationinfected 
From covid_deaths
where continent != '' and location not in ('European Union', 'High income', 'Upper middle income', 'World', 'Lower middle income', 'Low income')
Group by Location, Population
order by PercentPopulationInfected desc

Select 
	Location,
	Population,
	MAX(total_cases) as HighestInfectionCount, 
	case
		when Max((total_cases/population))*100 is null then null 
		when Max((total_cases/population))*100 is not null then trunc(cast(Max((total_cases/population))*100 as numeric),1)
	end as PercentPopulationInfected
From covid_deaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

-- 4. Analyze the variation of the population who got covid overtime, per location.

Select Location, Population, date, max(total_cases) as HighestInfectionCount,  trunc(cast(max((total_cases/population))*100 as numeric),1) as PercentPopulationInfected
From covid_deaths
where continent != '' and location not in ('European Union', 'High income', 'Upper middle income', 'World', 'Lower middle income', 'Low income')
Group by Location, Population, date
order by date, PercentPopulationInfected desc;

Select Location, Population, date, (total_cases) as HighestInfectionCount,  cast(((total_cases/population))*100 as numeric) as PercentPopulationInfected
From covid_deaths
Group by Location, Population, date, total_cases
order by date, PercentPopulationInfected desc;


-- LINK TO THE DASHBOARD:
-- https://public.tableau.com/app/profile/david6269/viz/Covid_Dashboard_16879713806820/Dashboard1









-- Queries I originally had, but excluded some because it created too long of video
-- Here only in case you want to check them out


-- 1.

Select dea.continent, dea.location, dea.date, dea.population
, MAX(vac.total_vaccinations) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
group by dea.continent, dea.location, dea.date, dea.population
order by 1,2,3




-- 2.
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 3.

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc



-- 4.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc



-- 5.

--Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where continent is not null 
--order by 1,2

-- took the above query and added population
Select Location, date, population, total_cases, total_deaths
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
order by 1,2


-- 6. 


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
From PopvsVac


-- 7. 

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc
