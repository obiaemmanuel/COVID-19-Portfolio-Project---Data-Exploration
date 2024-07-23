select * from PortfolioProject..CovidDeath
order by 3,4

--select * from PortfolioProject..CovidVaccination
--order by 3,4

--select the data we would be using

select location, date, total_cases, new_cases, total_deaths from PortfolioProject..CovidDeath
order by 1,2

-- looking at total cases vs total deaths
-- shows the likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as DeathPersentage from PortfolioProject..CovidDeath
where location like '%states%'
order by 1,2

-- Looking at the total cases vs the population 
-- shows what percentage of population has gotten covid
select location, date, population, total_cases, (total_cases / population) * 100 as InfectedPercentage from PortfolioProject..CovidDeath
where location like '%states%'
order by 1,2

-- Looking at countries with highest infection rate to population 
select location, MAX(cast(total_deaths as int)) as TotalDeathCount from PortfolioProject..CovidDeath
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc

-- Lets break things down by continent
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount from PortfolioProject..CovidDeath
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

select location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as DeathPersentage from PortfolioProject..CovidDeath
--where location like '%states%'
where continent is not null
order by 1,2 

-- Looking at total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations from PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccination vac

on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
order by 2,3


--looking at new vacination conducted per country 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated 

from PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccination vac

on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
order by 2,3

-- USE CTE

with PopVsVac (continent, date, location, population, rollingPeopleVaccinated, new_vaccinations) as 

(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated 

from PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccination vac

on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
--order by 2,3
)
select *, (rollingPeopleVaccinated/population) * 100 from PopVsVac

-- TEMP TABLE

Create Table #PercentPopulationVaccinated

(continent nvarchar(255), 
date datetime, 
location nvarchar(255), 
Population numeric,
New_vaccinations numeric,
rollingPeopleVaccinated numeric)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated 

from PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccination vac

on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
--order by 2,3

select *, (rollingPeopleVaccinated/population) * 100 from #PercentPopulationVaccinated

--CREATE VIEW TO STORE DATA FOR LATER