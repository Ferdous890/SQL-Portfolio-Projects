
Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases,new_cases, total_deaths, population
 From PortfolioProject..CovidDeaths
 order by 1,2

 -- Looking at Total Cases vs Total Deaths
 -- Shows likelihood of dying if you contract covid in your country 

 Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
 From PortfolioProject..CovidDeaths
 where location like '%states%'
 order by 1,2


 -- Looking at Total Cases vs Population 

 Select Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
 From PortfolioProject..CovidDeaths
 where location like '%states%'
 order by 1,2


 -- Looking at Countries with Highest Infection Rate compared to Population

 Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
 From PortfolioProject..CovidDeaths
 -- where location like '%states%'
 Group by Location, Population
 order by 4 desc


 -- Showing continents with Highest Death Count per Population

 Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
 From PortfolioProject..CovidDeaths
 -- where location like '%states%'
 Where continent is null
 Group by location 
 order by TotalDeathCount desc


 -- GLOBAL NUMBERS 

 select SUM(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, (Sum(cast(new_deaths as int)) / Sum(new_cases)) * 100 as DeathPercentage
 From PortfolioProject..CovidDeaths
  -- where location like '%states%'
  where continent is not null 
  -- Group By date
  order by 1,2


  -- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	  On dea.location = vac.location
	  and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE 

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	  On dea.location = vac.location
	  and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- TempTable

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location Nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	  On dea.location = vac.location
	  and dea.date = vac.date
-- where dea.continent is not null
-- order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	  On dea.location = vac.location
	  and dea.date = vac.date
 where dea.continent is not null
 -- order by 2,3


 Select *
 From #PercentPopulationVaccinated
