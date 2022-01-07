
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--Select Data To Be Used 
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 1,2

--Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Case_Fatality_Ratio 
FROM PortfolioProject..CovidDeaths
WHERE location = 'United States'
AND continent is not null
order by 1,2

--Looking at Total Cases vs Population 
--shows percentage of population that contracted covid

SELECT location, date, population, total_cases, ROUND((total_cases/population)*100,6) as CasePopulationPercent 
FROM PortfolioProject..CovidDeaths
WHERE location = 'United States'
AND continent is not null
order by 1,2

--Looking at Countries With Highest Infection Rate Compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
order by PercentPopulationInfected desc

--Showing the countries with highest death count per population 

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
order by TotalDeathCount desc

--LET'S BREAK THINGS UP BY CONTINENT
--Show continents with highest death count

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location
order by TotalDeathCount desc


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths,
       ROUND((SUM(cast(new_deaths as int))/SUM(new_cases))*100,4) as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
group by date
order by 1,2

--Looking at Total Population vs Vaccinations 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
       SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
	   dea.date) AS VacByDate
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE

WITH PopvsVac(Continent, Location, Date, Population, New_Vaccinations, VacByDate)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
       SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
	   dea.date) AS VacByDate
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
Select *, (VacByDate/Population)*100 as VacPercent
FROM PopvsVac
ORDER BY 2,3

GO
--Create Views for Later Use In Tableau 
CREATE VIEW PopvsVac as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
       SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
	   dea.date) AS VacByDate
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null;

GO

CREATE VIEW CasesvsDeaths as
--Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Case_Fatality_Ratio 
FROM PortfolioProject..CovidDeaths
WHERE location = 'United States'
AND continent is not null;

GO

CREATE VIEW GlobalNum as 
SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths,
       ROUND((SUM(cast(new_deaths as int))/SUM(new_cases))*100,4) as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
group by date;

GO

CREATE VIEW HighestInfection as
SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths,
       ROUND((SUM(cast(new_deaths as int))/SUM(new_cases))*100,4) as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
group by date;