SELECT *
FROM CovidDeaths$
where continent is not null
order by 3,4

--SELECT *
--FROM CovidVaccinations$
--order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths$
order by 1,2

-- Looking at Total CAses vs Total Deaths
--Shows likelihood of dying if you contract covid in your country 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
FROM CovidDeaths$
where location like '%States%'
order by 1,2

--looking at tototal cases vs population 
--shows what percentage of population got covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage 
FROM CovidDeaths$
--where location like '%States%'
order by 1,2

-- Looking at countries with highest infection rate compared to population 

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM CovidDeaths$
Group by location, population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population 
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths$
--where location like %state%
where continent is not null
Group by location
order by TotalDeathCount desc

--Break Things Down by Continent


--showing contintents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths$
--where location like %state%
where continent is not null
Group by continent
order by TotalDeathCount desc

--global numbers 
SELECT date,SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths$
--where location like '%States%'
where continent is not null 
group by date
order by 1,2

--Total cases
SELECT SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths$
--where location like '%States%'
where continent is not null 
--group by date
order by 1,2


--looking at Total population vs Vacinations 

Select dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations,
Sum(CONVERT(int,vac.new_vaccinations)) OVER (Partition by  dea.location Order by dea.location, dea.date) as RollingPeoplePeopleVacinated
--(RollingPeoplePeopleVacinated/population)*100
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE

with PopVsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations,
Sum(CONVERT(int,vac.new_vaccinations)) OVER (Partition by  dea.location Order by dea.location, dea.date) as RollingPeoplePeopleVacinated
--(RollingPeoplePeopleVacinated/population)*100
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopVsVac

--Temp Table 
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated 
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations,
Sum(CONVERT(int,vac.new_vaccinations)) OVER (Partition by  dea.location Order by dea.location, dea.date) as RollingPeoplePeopleVacinated
--(RollingPeoplePeopleVacinated/population)*100
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

--creating View to store data for later visualizations

Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations,
Sum(CONVERT(int,vac.new_vaccinations)) OVER (Partition by  dea.location Order by dea.location, dea.date) as RollingPeoplePeopleVacinated
--(RollingPeoplePeopleVacinated/population)*100
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select* 
From PercentPopulationVaccinated
