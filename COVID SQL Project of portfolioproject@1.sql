SELECT *FROM portfolioproject..coviddeath$ 
WHERE continent is not null
ORDER BY 3,4

--SELECT *FROM portfolioproject..covidvaccination$ ORDER BY 3,4

--SELECT DATA THAT WE ARE GOING TO USE 

SELECT location, date, total_cases, new_cases,total_deaths, population
FROM portfolioproject..coviddeath$ ORDER BY 1,2

-- LOOKING AT TOTAL CASES VS TOTAL DEATHS

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM portfolioproject..coviddeath$ ORDER BY 1,2

EXEC sp_help 'dbo.coviddeath$';

ALTER TABLE dbo.coviddeath$ ALTER COLUMN total_deaths FLOAT


SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM portfolioproject..coviddeath$ 
WHERE location like '%india%' -- Shows likelihood of dying if you contract covid in your country
ORDER BY 1,2



-- Looking total cases vs population
-- shows what percentage of population got covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS Cases_percentage
FROM portfolioproject..coviddeath$
WHERE location like '%india%'
ORDER BY 1,2


-- looking at countries with highest Infection rate compare to population

SELECT location, population, MAX(total_cases) AS Highest_infection_count, MAX((total_cases/population))*100 AS Cases_percentage
FROM portfolioproject..coviddeath$
GROUP BY location,population
ORDER BY Cases_percentage desc


-- showing Countries with the highest death count per population

SELECT location, MAX(cast(total_deaths AS INT)) AS totalDeathCount
FROM portfolioproject..coviddeath$
WHERE continent is not null
GROUP BY location 
ORDER BY totalDeathCount desc

-- LET'S BREAK THINK BY CONTINENTS

SELECT continent, MAX(CAST(total_deaths AS INT)) AS totalDeathCount
FROM portfolioproject..coviddeath$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY totalDeathCount desc


-- Showing the continents with highest death count per population

SELECT continent, MAX(CAST(total_deaths AS INT)) AS totalDeathCount
FROM portfolioproject..coviddeath$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY totalDeathCount desc


-- GLOBAL NUMBERS
SELECT date, SUM(CAST(new_cases AS INT))AS Total_cases,SUM(CAST(new_deaths AS INT)) AS Total_Deaths,SUM(CAST(new_deaths AS INT))/SUM(CAST(new_cases AS INT))*100 AS RJ_DEATH
FROM portfolioproject..coviddeath$
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- JOIN BOTH THE TABLE

SELECT * 
FROM portfolioproject..coviddeath$ dea
JOIN portfolioproject..covidvaccination$ vac
  ON dea.location = vac.location
  AND dea.date = vac.date


-- LOOKING AT TOTAL POPULATION VS VACINATION

SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RoolingPeopleVacccination
--, (RoolingPeopleVacccination/ population)*100 
FROM portfolioproject..coviddeath$ dea
JOIN portfolioproject..covidvaccination$ vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

  
-- USE CTE

WITH popvsvac (continent, location, date, population,new_vaccination, RoolingPeopleVacccination )
AS
(
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RoolingPeopleVacccination
--, (RoolingPeopleVacccination/ population)*100 
FROM portfolioproject..coviddeath$ dea
JOIN portfolioproject..covidvaccination$ vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3
)
SELECT*, (RoolingPeopleVacccination/ population)*100 AS POR
FROM popvsvac

-- TEMP TABLE

DROP TABLE IF EXISTS PercentagePopulationVaccinated;
CREATE TABLE PercentagePopulationVaccinated
(
continent NVARCHAR(255),
location NVARCHAR (255),
date DATETIME,
population NUMERIC,
new_vaccination NUMERIC,
RoolingPeopleVacccination NUMERIC 
)

INSERT INTO PercentagePopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RoolingPeopleVacccination
--, (RoolingPeopleVacccination/ population)*100 
FROM portfolioproject..coviddeath$ dea
JOIN portfolioproject..covidvaccination$ vac
  ON dea.location = vac.location
  AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3

SELECT*, (RoolingPeopleVacccination/ population)*100 AS POR
FROM PercentagePopulationVaccinated


-- CREATING VIEW TO STORE DATA FOR LATER VISULIZATION

create view PercentageVaccinated AS
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RoolingPeopleVacccination
--, (RoolingPeopleVacccination/ population)*100 
FROM portfolioproject..coviddeath$ dea
JOIN portfolioproject..covidvaccination$ vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
--ORDER BY 2,3

DROP VIEW PercentagePopulationVaccinated

 SELECT * FROM PercentageVaccinated