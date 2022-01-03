Select *
FROM PortfolioProject..[Covid Deaths]
Where continent is not null
order by 3,4

Select *
FROM PortfolioProject..[Covid Vaccinations]
order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..[Covid Deaths]
Where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract Covid in your country 

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..[Covid Deaths]
WHERE location like '%United Kingdom%'
and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select location, date,population,total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..[Covid Deaths]
WHERE location like '%United Kingdom%'
and continent is not null
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to population

Select location,population,Max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..[Covid Deaths]
--WHERE location like '%United Kingdom%'
GROUP BY location, population
order by PercentPopulationInfected Desc

--Showing Countries with Highest Death Count Per Population 

Select location,Max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..[Covid Deaths]
--WHERE location like '%United Kingdom%'
Where continent is not null
GROUP BY location
order by TotalDeathCount Desc

-- Let's break things down by CONTINENTS
-- Showing Continents with Highest Death Count

Select continent,Max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..[Covid Deaths]
--WHERE location like '%United Kingdom%'
Where continent is not null
GROUP BY continent
order by TotalDeathCount Desc

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM (cast (vac.new_vaccinations as bigint)) over (partition by dea.location Order by dea.location
, dea.date) as RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100 
FROM PortfolioProject..[Covid Deaths] dea
JOIN PortfolioProject..[Covid Vaccinations] vac
ON  dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2,3 
 
-- With CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM (cast (vac.new_vaccinations as bigint)) over (partition by dea.location Order by dea.location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
FROM PortfolioProject..[Covid Deaths] dea
JOIN PortfolioProject..[Covid Vaccinations] vac
ON  dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
--order by 2,3 
)
Select *, (RollingPeopleVaccinated/population)*100 
From PopvsVac

--Temp Table
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric,
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM (cast (vac.new_vaccinations as bigint)) over (partition by dea.location Order by dea.location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
FROM PortfolioProject..[Covid Deaths] dea
JOIN PortfolioProject..[Covid Vaccinations] vac
ON  dea.location = vac.location
    and dea.date = vac.date
--where dea.continent is not null
--order by 2,3  
Select * , (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

--Creating View to Store Data

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM (cast (vac.new_vaccinations as bigint)) over (partition by dea.location Order by dea.location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
FROM PortfolioProject..[Covid Deaths] dea
JOIN PortfolioProject..[Covid Vaccinations] vac
ON  dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
--order by 2,3  

Select * From PercentPopulationVaccinated