select * 
from CovidProject..CovidDeaths 
where continent is not null
order by 3,4

-- Displaying data about Covid Deaths

select location, date, total_cases, new_cases, total_deaths, population 
from CovidProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths 
-- Shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidProject..CovidDeaths
where location = 'India' and continent is not null
order by 1,2

-- Total cases vs Population
-- Shows what percentage of populations got covid
select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from CovidProject..CovidDeaths
where location = 'India' and continent is not null
order by 1,2

-- Countries with Highest Infection Rate compared to Population
select location, max(total_cases) as HighestInfectionCount, population, max((total_cases/population))*100 as PercentPopulationInfected
from CovidProject..CovidDeaths
where continent is not null
group by location, population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population
select location, max(cast(total_deaths as int)) as HighestDeathCount, population
from CovidProject..CovidDeaths
where continent is not null
group by location, population
order by HighestDeathCount desc

-- Analysis based on continent
-- Continents with Highest Death Count per Population
select location, max(cast(total_deaths as int)) as HighestDeathCount
from CovidProject..CovidDeaths
where continent is null
group by location
order by HighestDeathCount desc

-- Global Numbers

-- Death cases vs Infected cases around the world based on date
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from CovidProject..CovidDeaths
where continent is not null
group by date
order by date

-- Death cases vs Infected cases around the world 
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from CovidProject..CovidDeaths
where continent is not null



select * 
from CovidProject..CovidVaccinations

-- Joining Death and Vaccination table
select * 
from CovidProject..CovidDeaths dea
join CovidProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date

-- Total Populations vs Vaccination
with PopvsVace (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) as
(select dea.continent, dea.location, dea.date, population, new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidProject..CovidDeaths dea
join CovidProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
-- order by 1,2,3
)
select *, (RollingPeopleVaccinated/population)*100 as PercentageVaccinated
from PopvsVace

-- Temp Table

drop table if exists PercentPopulationVaccinated
create table PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, population, new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidProject..CovidDeaths dea
join CovidProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
-- order by 1,2,3

select *, (RollingPeopleVaccinated/population)*100 as PercentageVaccinated
from PercentPopulationVaccinated

-- Creating View to store data 

drop view if exists PercentPopulationVaccinated

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, population, new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidProject..CovidDeaths dea
join CovidProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
-- order by 1,2,3

select *
from PercentPopulationVaccinated