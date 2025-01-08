select location, date,total_cases, new_cases, total_deaths, population
from PortfolioProject..Coviddeaths
order by 1,2


--Death Percentage compared to Total Cases

select location, date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..Coviddeaths
where continent is not null and total_cases!= 0
order by 1,2


-- Looking at total cases and population
-- percentage of population infected with covid

select location, date,total_cases, population, (total_cases/population)*100 as CovidPercentage
from PortfolioProject..Coviddeaths
where continent is not null
order by 1,2


--coutries with highest infection rate compared to population

select location,max(total_cases) as HighestInfectionCount, population, (max(total_cases)/population)*100 as CovidInfectionPercentage
from PortfolioProject..Coviddeaths
where continent is not null
group by location, population
order by CovidInfectionPercentage desc


-- Countries with highest Death Rate compared to population

select location,max(total_deaths) as HighestDeathCount, population, (max(total_deaths)/population)*100 as CovidDeathPercentage
from PortfolioProject..Coviddeaths
where continent is not null
group by location, population
order by CovidDeathPercentage desc


--Looking at Inffection count & Death Count by CONTINENTS
--Highest Death Count
select continent,max(total_deaths) as HighestDeathCount
from PortfolioProject..Coviddeaths
where continent is not null
group by continent
order by HighestDeathCount desc

--Highest Infection Count
select continent,max(total_cases) as HighestInfectionCount
from PortfolioProject..Coviddeaths
where continent is not null
group by continent
order by HighestInfectionCount desc


-- Looking at Percent Infection rate & Death rate by CONTINENTS
--Percent Deathrate
select continent,max(total_deaths) as HighestDeathCount, sum(population) as TotalPopulation, (max(total_deaths)/sum(population))*100 as CovidDeathPercentage
from PortfolioProject..Coviddeaths
where continent is not null
group by continent
order by CovidDeathPercentage desc

--Percent Infectionrate
select continent,max(total_cases) as HighestinfectionCount, sum(population) as TotalPopulation, (max(total_cases)/sum(population))*100 as CovidInfectionPercentage
from PortfolioProject..Coviddeaths
where continent is not null
group by continent
order by CovidInfectionPercentage desc


-- Looking at GLOBAL infections and deaths data
-- Global Death percentage in comparison to Global Infection count by date

select date, sum(new_cases) as GolbalInfectionCount, sum(new_deaths) as GlobalDeathCount, (sum(new_deaths)/sum(new_cases))*100 as GlobalDeathPercent
from PortfolioProject..Coviddeaths
where continent is not null and new_cases!= 0
group by date
having sum(new_cases) > sum(new_deaths)
order by date

--Global Death percentage in comparison to Global Infection count
select sum(new_cases) as GolbalInfectionCount, sum(new_deaths) as GlobalDeathCount, (sum(new_deaths)/sum(new_cases))*100 as GlobalDeathPercent
from PortfolioProject..Coviddeaths
where continent is not null and new_cases!= 0




-- Looking at Toal Population vs vaccinations
----Rolling count of vaccinations by location and date

select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,sum(convert(bigint,new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccineCount
from PortfolioProject..Coviddeaths dea
join PortfolioProject..Covidvaccines vac on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3

-----creating a CTE as we cannot perform an aggregate function inside MAX() function

with Vaccinerate (continent,location,date,population,new_vaccinations,RollingVaccineCount)
as
(
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(convert(bigint,new_vaccinations)) 
 over (partition by dea.location order by dea.location, dea.date) 
 as RollingVaccineCount
from PortfolioProject..Coviddeaths dea
 join PortfolioProject..Covidvaccines vac on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
)
select continent, location, date, population, RollingVaccineCount,
 ((RollingVaccineCount)/population)*100 as PercentPopulationVaccinated
from vaccinerate
order by location, date

create view PopulationVaccinated as
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(convert(bigint,new_vaccinations)) 
 over (partition by dea.location order by dea.location, dea.date) 
 as RollingVaccineCount
from PortfolioProject..Coviddeaths dea
 join PortfolioProject..Covidvaccines vac on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

select * from PopulationVaccinated


