
select *
from PortfolioProject1..CovidDeaths
where continent is not null
order by 3,4

/*Select *
from PortfolioProject1..CovidVaccinations
order by 3,4*/

select Location,date,total_cases,new_cases,total_deaths,
population
from PortfolioProject1..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths

-- Shows likelihood of dying if you contract covid in your country
select Location,date,total_cases,total_deaths,
		(total_deaths/total_cases)*100 DeathPercentage
from PortfolioProject1..CovidDeaths
where location like '%india%'
order by 1,2

-- Total Cases vs Population
-- Shows what % of population got covid 

select Location,date,Population,total_cases,
		(total_cases/population)*100 DeathPercentage
from PortfolioProject1..CovidDeaths
--where location like '%india%'
order by 1,2


-- Looking at Countries with Highest Infection Rate comapred to Population

select Location,Population,max(total_cases) HighestInfectionCount,max((total_cases/population))*100
	PercentPopulationInfected
from PortfolioProject1..CovidDeaths
--where location like '%india%'
group by location,population
order by PercentPopulationInfected desc

-- Countries with highest death count per population

select continent,max(cast(total_deaths as int)) TotalDeathCount
from PortfolioProject1..CovidDeaths
--where location like '%india%'
where continent is not null
group by continent
order by TotalDeathCount desc

-- Total Death Count by Continent

select location,max(cast(total_deaths as int)) TotalDeathCount
from PortfolioProject1..CovidDeaths
--where location like '%india%'
where continent is null
group by location
order by TotalDeathCount desc

-- Continents with highest death count per population

select continent,max(cast(total_deaths as int)) TotalDeathCount
from PortfolioProject1..CovidDeaths
--where location like '%india%'
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global Numbers

select date,sum(new_cases),sum(cast(new_deaths as int)),
		sum(cast(new_deaths as int))/sum(new_cases)*100 DeathPercentage
from PortfolioProject1..CovidDeaths
--where location like '%india%'
where continent is not null
--group by date
order by 1,2


-- Total Population vs Vaccinations

Select dea.continent,dea.location,dea.date,
	dea.population,vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) 
	over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated

From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE

with PopvsVac (Continent,Location,Date,Population,New_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,
	dea.population,vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) 
	over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Temp Table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location  nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,
	dea.population,vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) 
	over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated

From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

Select *,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Create Views

Create view PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,
	dea.population,vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) 
	over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated

From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * 
From PercentPopulationVaccinated