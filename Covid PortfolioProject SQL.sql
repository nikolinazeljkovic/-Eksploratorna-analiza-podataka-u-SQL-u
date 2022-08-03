
Select *
From PortfolioProject.dbo.CovidDeaths$
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject.dbo.CovidVaccinations$
--order by 3,4

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths$
Where continent is not null
order by 1,2

--Posmatramo total_cases vs total_deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths$
Where location like '%serbia%'
Where continent is not null
order by 1,2

--Posmatrajmo total_cases vs population
--Pokazuje procenat populacije koji su imali Covid
Select location, date, total_cases, population, (total_deaths/population)*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths$
--Where location like '%serbia%'
order by 1,2

--Looking at Country with the highest infection rate copmared to population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_deaths/population))*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths$
--Where location like '%serbia%'
Group by location, population
order by PercentPopulationInfected desc

--Showing Countries with the highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths$
--Where location like '%serbia%'
Where continent is not null
Group by location
order by TotalDeathCount desc


--Lets break things down by the contintet

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths$
--Where location like '%serbia%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


--Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths$
--Where location like '%serbia%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

Select date,  SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths , SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage --Nisu istog tipa pa ih prebacujemo u int
From PortfolioProject.dbo.CovidDeaths$
--Where location like '%serbia%'
Where continent is not null
Group by date
order by 1,2

--PRIKAZ SVIH UKUPNO (broj zarazenih i broj umrlih) zakljucno sa 02.08.2022.

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths , SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage --Nisu istog tipa pa ih prebacujemo u int
From PortfolioProject.dbo.CovidDeaths$
--Where location like '%serbia%'
Where continent is not null
order by 1,2

--Spaja tabele zajedno:  po zajednickim kolonama location i date

Select *
From PortfolioProject..CovidDeaths$  dea
Join PortfolioProject..CovidVaccinations$ vac
    On dea.location = vac.location
	and dea.date = vac.date

-- Gledamo ukupan broj vakcinisanih u odnosu na populaciju (ukupan broj vakcinisanih u svijetu)

Select dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as int)
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$  dea
Join PortfolioProject..CovidVaccinations$ vac
    On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
and cast(vac.new_vaccinations as int) is not null
order by 2,3
--Greska :
--Arithmetic overflow error converting expression to data type int.

--GRESKA JE INT KOD CAST-a! TREBA BIGINT
--Pravi novu tabelu iz one dvije
--Nacin dobijanja priveremenih tabela zove se CTE

With PopVsVac(Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as int)
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$  dea
Join PortfolioProject..CovidVaccinations$ vac
    On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--and cast(vac.new_vaccinations as int) is not null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/Population)*100 as ProcenatVakcinisanih
From PopVsVac


--TEMP TABLE

Drop table if exists #PercentagePopulationVaccinated
Create table #PercentagePopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as int)
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$  dea
Join PortfolioProject..CovidVaccinations$ vac
    On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--and cast(vac.new_vaccinations as int) is not null
--order by 2,3

Select *,(RollingPeopleVaccinated/Population)*100 as ProcenatVakcinisanih
From #PercentagePopulationVaccinated



--Creating View to store data for later visualisations

Create view PercentagePopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$  dea
Join PortfolioProject..CovidVaccinations$ vac
    On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--and cast(vac.new_vaccinations as int) is not null
--order by 2,3

Select *
From PercentagePopulationVaccinated