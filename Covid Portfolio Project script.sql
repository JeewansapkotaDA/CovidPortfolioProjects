Select*
From PortfolioProject..CovidDeaths$
Order by 3,4

Select *
From PortfolioProject..CovidVaccinations$
Order by 3,4

--Select Data that we are going to be using 

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
Order by 1,2

--Loking at the total Cases VS total deaths 
--Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (Cast(total_deaths  as int) / Cast(total_cases  as int))*100 as DeathPercentage
From PortfolioProject..CovidDeaths$ 
Where location like '%states%'
Order by 1,2


--Looking at the total cases vs population
--Shows what percentage of population get covid
Select location, date, total_cases, population, (Cast(total_cases as int) / Cast (total_cases as int)) as CovidPositive
From PortfolioProject..CovidDeaths$ 
--Where location like '%states%'
Order by 1,2


-- Looking at the country which has the highest infection rate compare to the population 

Select location, population, MAX(total_cases) as HighestInfectionCount, Max(cast(total_cases as decimal)/cast(population as decimal))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$ 
Group by population, location, population, total_cases
Order by PercentPopulationInfected desc


--Showing countries with Highest Death Count per Population 

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathsCount
From PortfolioProject..CovidDeaths$
Group By Location
Order By TotalDeathsCount desc


--Let's Break things down by continent 

--Showing continents with the highest death count per population 
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathsCount
From PortfolioProject..CovidDeaths$
Where continent is not null
Group By continent
Order By TotalDeathsCount desc

-- Global Numbers 

Select SUM(new_cases) as total_cases, SUM(Cast(new_deaths as int)) as total_deaths, SUM(Cast(new_deaths as int)) / SUM(cast(new_cases as int))*100 as DeathPercentage
From PortfolioProject..CovidDeaths$ 
--Where location like '%states%'
Where Continent is not null
--Group by date
Order by 1,2


--Looking at total population vs vaccinations 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 1,2,3         



-- USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3         
)
Select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac



--TEMP TABLE

DROP Table if Exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3         

Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to Store data for later visualizations 

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3         


Select*
From #PercentPopulationVaccinated