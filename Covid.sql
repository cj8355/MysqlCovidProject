select * from covidproject.coviddeaths
where continent = '';

/* Select data to use */

Select Location, cast(date as datetime), total_cases, new_cases, total_deaths, population
From covidproject.coviddeaths
order by 1,2;

/* Looking at Total Cases vs Total Deaths */
-- Shows likelihood of dying if you contract Cvoid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From covidproject.coviddeaths
where Location like '%states%'
order by 1,2 desc;

/* Total cases versus population */
-- % of population that got Covid
Select Location, date, population,total_cases , (total_cases/population) * 100 as PercentageInfected
From covidproject.coviddeaths
where Location like '%states%'
order by 1,2 ;

-- Looking at Countries with Highest infection rate compared to population
Select Location, population, MAX(total_cases) as HighestInfectionCount , Max((total_cases/population)) * 100 as PercentagePopulationInfected
From covidproject.coviddeaths
Group by Location, population
order by PercentagePopulationInfected desc;


-- LET's Look by Continent
Select location, max(cast(total_deaths as UNSIGNED)) as TotalDeathCount 
From covidproject.coviddeaths
Where continent = ''
Group by location
order by TotalDeathCount desc;

-- Showing countries with highest death count per population
Select Location, MAX(cast(total_deaths as decimal)) as TotalDeathCount 
From covidproject.coviddeaths
Where continent != ''
Group by Location
order by TotalDeathCount desc;


-- Global Numbers by Date
Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as UNSIGNED)) as total_deaths, (sum(cast(new_deaths as UNSIGNED)) / sum(cast(new_cases as UNSIGNED))*100) as DeathPercentage
From covidproject.coviddeaths
where continent != ''
Group by date
order by 1,2 ;

-- Global Numbers
Select  sum(new_cases) as total_cases, sum(cast(new_deaths as UNSIGNED)) as total_deaths, (sum(cast(new_deaths as UNSIGNED)) / sum(cast(new_cases as UNSIGNED))*100) as DeathPercentage
From covidproject.coviddeaths
where continent != ''
order by 1,2 ;


-- Looking at total population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as UNSIGNED)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated,
(RollingPeopleVaccinated/population)*100
from covidproject.coviddeaths dea
Join covidproject.covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent != ''
order by 2,3;



-- Use CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as UNSIGNED)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from covidproject.coviddeaths dea
Join covidproject.covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent != ''
)
Select *, (RollingPeopleVaccinated/Population)*100
 From PopvsVac;
 
 
 -- TEMP Table
 Drop Table if Exists PercentPopulationVaccinated;
 Create Temporary Table PercentPopulationVaccinated
 (
 Continent varchar(255),
 Location varchar(255),
 Date datetime,
 Population int,
 New_vaccinations int,
 RollingPeopleVaccinated int
 );
 
Insert into PercentPopulationVaccinated(Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as UNSIGNED)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from covidproject.coviddeaths dea
Join covidproject.covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
/*where dea.continent != '' */;

Select *, (RollingPeopleVaccinated/Population)*100
 From PercentPopulationVaccinated;
 
 -- Creating view to store data for viz
 
 Create View PercentPopulationVaccinated as
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as UNSIGNED)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from covidproject.coviddeaths dea
Join covidproject.covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent != ''
;


