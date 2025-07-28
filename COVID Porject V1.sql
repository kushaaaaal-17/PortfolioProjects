
-- QUERY TO VIEW ENTIRE TABLE
SELECT *
FROM PortfolioProjectsDB..CovidDeaths
ORDER BY 1, 2

-- Selecting data that we will be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjectsDB..CovidDeaths
ORDER BY 1, 2

-- Looking at the Total Cases vs Total Deaths
-- to show the likelihood of dying if COVID +ve
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 AS death_pct
FROM PortfolioProjectsDB..CovidDeaths
WHERE location = 'India'
ORDER BY 1, 2

-- Looking at Total Cases vs The Population (as a percentage)
-- Shows what % contracted COVID
SELECT location, date, total_cases, population, (total_cases / population) * 100 AS Cases_Per_Pop
FROM PortfolioProjectsDB..CovidDeaths
-- WHERE location = 'India'
ORDER BY 1, 2

-- Finding out the countries with the highest infection rate (per pop)
SELECT location, population, MAX(total_cases) AS HighestInfectionCost, MAX(total_cases/population) * 100 AS PercentPopInfected
FROM PortfolioProjectsDB..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopInfected DESC



-- Examining things by CONTINENT
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathsPerCont
FROM PortfolioProjectsDB..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathsPerCont DESC



-- Showing countries with the Highest Death Count per Population
SELECT location, population, MAX(cast(total_deaths as int)) AS HighestRecordedDeaths
FROM PortfolioProjectsDB..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY location, population
ORDER BY HighestRecordedDeaths DESC

-- Trial Queries
WITH LatestDeaths AS (
    SELECT continent, location, MAX(CAST(total_deaths AS INT)) AS TotalDeaths
    FROM PortfolioProjectsDB..CovidDeaths
    WHERE continent IS NOT NULL
    GROUP BY continent, location
)
SELECT continent, SUM(TotalDeaths) AS TotalDeathCount
FROM  LatestDeaths
GROUP BY continent
ORDER BY TotalDeathCount DESC;


-- Looking at the GLOBAL NUMBERS
-- The query below shows the number of cases across the world on each date.
-- not filtered as I wanted to examine the global numbers
SELECT date, SUM(new_cases) AS TotalWorldCases, SUM(cast(new_deaths as int)) AS TotalWorldDeaths,
(SUM(cast(new_deaths as int))/SUM(new_cases)) * 100 AS GlobalDeathsPerCases
FROM PortfolioProjectsDB..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Joining the CovidVaccinations Table
-- Looking at Total Population Versus Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations AS VaccinationNumbers,
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingTotal_PeopleVacciated
-- (RollingTotal_PeopleVaccinated/dea.population) AS RatioOfVaccinated
-- we used ORDER BY with date as we wanted to see the rolling total. IN the case of Albania (row 756) we can see it adds the number date to date
FROM PortfolioProjectsDB..CovidDeaths dea
JOIN PortfolioProjectsDB..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- Using a CTE
WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProjectsDB..CovidDeaths dea
JOIN PortfolioProjectsDB..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population) * 100
FROM PopVsVac

-- Creating View for Later Use
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations AS VaccinationNumbers,
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingTotal_PeopleVacciated
-- (RollingTotal_PeopleVaccinated/dea.population) AS RatioOfVaccinated
-- we used ORDER BY with date as we wanted to see the rolling total. IN the case of Albania (row 756) we can see it adds the number date to date
FROM PortfolioProjectsDB..CovidDeaths dea
JOIN PortfolioProjectsDB..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
