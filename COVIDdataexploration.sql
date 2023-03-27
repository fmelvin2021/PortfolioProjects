--SELECT *
--FROM Portfolio23.dbo.CovidDeaths
--order by 3,4

--SELECT *
--FROM Portfolio23..CovidVaccinations$
--order by 3,4

/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

-- Select Data that we are going to start with.

--SELECT location, date, total_cases, new_cases, total_deaths, population
--FROM Portfolio23..CovidDeaths
--Where continent is not null 
--order by 1,2

--Total Cases vs. Total Deaths 
--Shows the likelihood of dying from Covid
--Had to change datatype NCARCHAR to float

--SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS float)/CAST(total_cases AS float))*100 AS death_rate
--FROM Portfolio23..CovidDeaths
--Where location ='United States'
--and continent is not null
--order by 1,2

--Total Cases vs. Population
--What % of population contracted COVID?

--SELECT location, date, population, total_cases, (CAST(total_cases AS float)/population)*100 AS percent_population_infected
--FROM Portfolio23..CovidDeaths
--Where location ='United States'
--order by 1,2

--Countries with Highest Infection Rate compared to Population

--SELECT continent, location, population, MAX(total_cases) AS HighestInfectionCount, MAX(CAST(total_cases AS float)/population)*100 AS percent_population_infected
--FROM Portfolio23..CovidDeaths
--Where continent is not null
--group by continent, location, population
--order by percent_population_infected desc;

--Countries with highest death count per population

--SELECT location, continent, MAX(Cast(total_deaths AS bigint)) AS TotalDeathCount
--FROM Portfolio23..CovidDeaths
--Where continent is not null
--group by location, continent
--order by TotalDeathCount desc;

--Viewing the data by Continent
--Continents with highest death count per population

--SELECT continent, MAX(Cast(total_deaths AS bigint)) AS TotalDeathCount
--FROM Portfolio23..CovidDeaths
--Where continent is not null
--group by continent
--order by TotalDeathCount desc;

----Global Numbers 

--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(New_Cases))*100 as DeathPercentage
--From Portfolio23..CovidDeaths
----where continent is not null 
--order by 1,2


--Joining the CovidDeaths and CovidVaccination tables
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations AS float)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM Portfolio23..CovidDeaths AS dea
JOIN Portfolio23..CovidVaccinations$ AS vacc
	ON dea.location = vacc.location
	AND dea.date = vacc.date
WHERE dea.continent is not null
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, SUM(CAST(vacc.new_vaccinations AS float)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio23..CovidDeaths AS dea
Join Portfolio23..CovidVaccinations$ AS vacc
	On dea.location = vacc.location
	and dea.date = vacc.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, SUM(CAST(vaCc.new_vaccinations AS float)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio23..CovidDeaths AS dea
Join Portfolio23..CovidVaccinations$ AS vacc
	On dea.location = vacc.location
	and dea.date = vacc.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated







