Select * 
From PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 3,4

--Select * 
--From PortfolioProject.dbo.CovidVaccinations
--order by 3,4

-- Select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
where continent is not null 
AND
location like '%Indonesia%'
order by 1,2

-- Looking at Total_Cases vs Population
-- Shows what percentage of population got Covid
Select Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
where continent is not null
--Where location like '%Indonesia%'
order by 1,2


-- Looking at Countries with highest infection rate compared to population
Select Location, population, max(total_cases) as HighestInfectionsCount, max((total_cases/population)*100) as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
--Where location like '%Indonesia%'
where continent is not null
group by location, population
order by PercentPopulationInfected desc

-- Showing countries with the highest death count per population
Select Location, max(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject.dbo.CovidDeaths
--Where location like '%Indonesia%'
where continent is not null
group by location, population
order by TotalDeathCount desc



--- Lets break things down by continent
Select location, max(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject.dbo.CovidDeaths
--Where location like '%Indonesia%'
where continent is null
group by location
order by TotalDeathCount desc


-- Showing Continent with highest total death count
Select continent, location, max(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject.dbo.CovidDeaths
--Where location like '%Indonesia%'
where continent is not null
group by continent
order by TotalDeathCount desc

-- join deaths and vaccination data
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Looking at the total population vs vaccination
--USE CTE

With PopvsVac(Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100 
from PopvsVac



-- Temp Table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
-- order by 2,3

select *, (RollingPeopleVaccinated/Population)*100 
from #PercentPopulationVaccinated



-- Global numbers

Select sum(new_cases) as total_cases,
sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 1,2


-- Creating view to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
-- order by 2,3

select * 
from PercentPopulationVaccinated