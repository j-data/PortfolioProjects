select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4


--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

------------- Data Exploration -------------
-- Select Data to be used
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


-- Total Deaths vs Total Cases: What percent of people who had covid died?
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2
-- Shows 1.78% likelihood of dying if one contracted Covid in US as at 04/30/2021


-- Total Cases vs Population: What percent of people in that location got covid?
select location, date, total_cases, population, (total_cases/population)*100 as CasesPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2
-- Shows 9.77% likelihood of contracting Covid in US as at 04/30/2021


-- Countries with the Highest Infection rate vs Population
select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by PercentPopulationInfected desc
-- Shows Andorra had the highest Infection Rate


-- Looking at Countries with the Highest Mortality rate vs Population
select location, population, Max(cast(total_deaths as int)) as TotalDeathCount, Max((total_deaths/population))*100 as PercentPopulationDead
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by TotalDeathCount desc
-- Shows the US had the highest Death Rate


-- Continents with the Highest Mortality rate vs Population
select location, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc
-- Shows Europe had the highest Death Rate



-- Global Daily Cumulative Deaths
select date, Sum(new_cases) as TotalCases, Sum(cast(new_deaths as int)) as TotalDeaths, (Sum(cast(new_deaths as int))/ Sum(new_cases)*100) as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2 desc
-- Shows Europe had the highest Death Rate

-- Global Daily Cumulative Deaths
select Sum(new_cases) as TotalCases, Sum(cast(new_deaths as int)) as TotalDeaths, (Sum(cast(new_deaths as int))/ Sum(new_cases)*100) as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2 desc
-- Shows total of 2% Global Death Rate 




------------- Working with the Vaccination dataset -------------
select *
from PortfolioProject..CovidVaccinations

-- Total Population vs Vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	-- join on location and date --
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3




-- Percent Vaccinated out of Total Population 
-- Use CTE 
With PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccinated)
as(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	-- join on location and date --
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingVaccinated/ population)*100 as PercentPopulationVaccinated
from PopvsVac


-- Use a Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinated

from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	-- join on location and date --
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
select *, (RollingVaccinated/ population)*100 as PercentPopulationVaccinated
from #PercentPopulationVaccinated



------------- Creating Views to store data for later visualizations -------------
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinated

from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	-- join on location and date --
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
