--SELECT *
--FROM dbo.CovidDeaths

--SELECT *
--FROM dbo.CovidVaccines

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths

--total cases and total deaths
-- covid death percentage in nigeria
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM dbo.CovidDeaths
WHERE Location like '%nigeria%'

-- total cases and population

SELECT Location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
FROM dbo.CovidDeaths
WHERE Location like '%nigeria%'



--Countries with highest infection rate compared with population

SELECT Location, population, MAX(total_cases) as HighestNoCases, MAX((total_cases/population))*100 as InfectedPopulationPercentage
FROM dbo.CovidDeaths
GROUP BY Location, population
ORDER BY InfectedPopulationPercentage DESC


--Countries with highest death count per pop

SELECT Location, population, MAX(total_deaths) as HighestNoDeaths, MAX((total_deaths/population))*100 as DeathsperPopulationPercentage
FROM dbo.CovidDeaths
GROUP BY Location, population
ORDER BY DeathsperPopulationPercentage DESC



SELECT Location, MAX(CAST(total_deaths as int)) as TotalDeeathsCount
FROM dbo.CovidDeaths
WHERE continent is null
GROUP BY Location
ORDER BY TotalDeeathsCount DESC



SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeeathsCount
FROM dbo.CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeeathsCount DESC


SELECT Location, MAX(CAST(total_deaths as int)) as TotalDeeathsCount
FROM dbo.CovidDeaths
WHERE Location like '%nigeria%'
GROUP BY Location
--ORDER BY TotalDeeathsCount DESC


--global numbers

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases) * 100 as TotalDeathPercentage
FROM dbo.CovidDeaths
WHERE continent is not null


--viewing both tables (covid deaths and covid vaccines)
SELECT *
FROM dbo.CovidDeaths as dea
JOIN dbo.CovidVaccines as vac
	ON dea.location = vac.location and dea.date = vac.date
ORDER BY 1,2

--total pop vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS int)) OVER 
(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingSumofVaccinated
FROM dbo.CovidDeaths as dea
JOIN dbo.CovidVaccines as vac
	ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 1,2


--using cte
--calculating the percentage of the population vaccinated

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingSumofVaccinated) as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS int)) OVER 
(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingSumofVaccinated
FROM dbo.CovidDeaths as dea
JOIN dbo.CovidVaccines as vac
	ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 1,2
)
SELECT *, (RollingSumofVaccinated/population)*100 as PercentageVaccinated
FROM PopvsVac


WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingSumofVaccinated) as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS int)) OVER 
(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingSumofVaccinated
FROM dbo.CovidDeaths as dea
JOIN dbo.CovidVaccines as vac
	ON dea.location = vac.location and dea.date = vac.date
WHERE dea.location like '%nigeria%'
--ORDER BY 1,2
)
SELECT *, (RollingSumofVaccinated/population)*100 as PercentageVaccinated
FROM PopvsVac


--creating view for visualization

CREATE VIEW PercentageVaccinated as
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingSumofVaccinated) as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS int)) OVER 
(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingSumofVaccinated
FROM dbo.CovidDeaths as dea
JOIN dbo.CovidVaccines as vac
	ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 1,2
)
SELECT *, (RollingSumofVaccinated/population)*100 as PercentageVaccinated
FROM PopvsVac




CREATE VIEW DeathCountInContinentAffected as
SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeeathsCount
FROM dbo.CovidDeaths
WHERE continent is not null
GROUP BY continent
--ORDER BY TotalDeeathsCount DESC




CREATE VIEW CovidDeathPercentageNigeria as
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM dbo.CovidDeaths
WHERE Location like '%nigeria%'


CREATE VIEW InfectedPercentageNigeria as
SELECT Location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
FROM dbo.CovidDeaths
WHERE Location like '%nigeria%'


CREATE VIEW PercentageVaccinatedNigeria as
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingSumofVaccinated) as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS int)) OVER 
(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingSumofVaccinated
FROM dbo.CovidDeaths as dea
JOIN dbo.CovidVaccines as vac
	ON dea.location = vac.location and dea.date = vac.date
WHERE dea.location like '%nigeria%'
--ORDER BY 1,2
)
SELECT *, (RollingSumofVaccinated/population)*100 as PercentageVaccinated
FROM PopvsVac