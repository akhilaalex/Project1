/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions,
Aggregate Functions, Creating Views, Converting Data Types
*/


select * from project1 ..CovidDeaths order by 3,4
select * from project1 ..CovidVaccinations order by 3,4

-- Select the Data that we are going to be starting with

select location,date,total_cases,new_cases,total_deaths,population 
from project1..CovidDeaths order by 1,2


--Looking at total case with total death
-- Shows likelihood of dying if you contract covid in your country

select location,date,total_cases,
total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from project1..CovidDeaths where location like '%Canada%' order by 1,2


--looking at population vs total cases
-- Shows what percentage of population infected with Covid

select location,date,population,total_cases,
(total_cases/population)*100 as Percentageofpopulationinfected
from project1..CovidDeaths where location like '%Canada%'
order by 1,2



--looking at the countries with highest infection rate compared to population

select location,population,MAX(total_cases) as HighestInfectionCount,
MAX((total_cases/population)*100) as Percentageofpopulationinfected
from project1..CovidDeaths 
--where location like '%Canada%'
group by location,population
order by Percentageofpopulationinfected desc



--looking countries with highest death count 

select location,MAX(cast(total_deaths as int)) as TotalDeathCount
from project1..CovidDeaths 
where continent is not null
group by location
order by TotalDeathCount desc


--looking at continents with highest death count per population

select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
from project1..CovidDeaths 
where continent is not null
group by continent
order by TotalDeathCount desc



/*--looking continents with highest death count 
select location,MAX(cast(total_deaths as int)) as TotalDeathCount
from project1..CovidDeaths 
where continent is null
group by location
order by TotalDeathCount desc */


--Global death precentage

select Sum(cast(new_deaths as int)) as TotalDeath, Sum(new_cases) as total_cases,
(Sum(cast(new_deaths as int))/Sum(new_cases))*100 as death_percentage
from project1..CovidDeaths 
where continent is not null
--group by date
order by 1,2



-- Total Population vs Vaccinations


--Joining Coviddeaths and Covidvaccinations

select * from project1..CovidDeaths d join project1..CovidVaccinations v
on d.location=v.location and d.date=v.date


--Shows Percentage of Population that has recieved at least one Covid Vaccine

select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(convert(int,v.new_vaccinations)) OVER (partition by d.location 
order by d.location,d.date) as peoplevaccinated
from project1..CovidDeaths d join project1..CovidVaccinations v
on d.location=v.location and d.date=v.date
where d.continent is not null
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

with popvsvac(continent,location,date,population,new_vaccinations,peoplevaccinated)
as(
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(convert(int,v.new_vaccinations)) OVER (partition by d.location 
order by d.location,d.date) as peoplevaccinated
from project1..CovidDeaths d join project1..CovidVaccinations v
on d.location=v.location and d.date=v.date
where d.continent is not null
)
--select * from popvsvac
select *, (peoplevaccinated/population)*100 as percentageofvaccinatedpopulation
from popvsvac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP table if exists #percentage_population_vaccinated
create table #percentage_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinated numeric,
peoplevaccinated numeric

)

insert into #percentage_population_vaccinated
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(convert(int,v.new_vaccinations)) OVER (partition by d.location 
order by d.location,d.date) as peoplevaccinated
from project1..CovidDeaths d join project1..CovidVaccinations v
on d.location=v.location and d.date=v.date
where d.continent is not null

select *, (peoplevaccinated/population)*100 as percentageofvaccinatedpopulation
from #percentage_population_vaccinated

--Creating view for percentage of vaccinated population(storing data for later visualizations)

create view percentage_population_vaccinated1 as
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(convert(int,v.new_vaccinations)) OVER (partition by d.location 
order by d.location,d.date) as peoplevaccinated
from project1..CovidDeaths d join project1..CovidVaccinations v
on d.location=v.location and d.date=v.date
where d.continent is not null

select * from percentage_population_vaccinated1


