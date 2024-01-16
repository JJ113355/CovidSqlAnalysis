USE CovidSql;


SELECT * FROM CovidDeaths
WHERE continent is not null
--348099 rows

SELECT * FROM CovidDeaths;
--365565 Rows


-------------------------------------------------------------------------------------------------------
--Change the Date Format

ALTER TABLE CovidDeaths
ADD DateConverted Date;

UPDATE CovidDeaths
SET DateConverted = CONVERT(Date,date)

ALTER TABLE CovidVaccinations
ADD DateConverted Date;

UPDATE CovidVaccinations
SET DateConverted = CONVERT(Date,date)


-- Dropping Old Date Column
ALTER TABLE CovidSql.dbo.CovidDeaths
DROP COLUMN date;

ALTER TABLE CovidSql.dbo.CovidVaccinations
DROP COLUMN date;

-------------------------------------------------------------------------------------------------------
--Removing Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY continent,
				 Location,
				 population,
				 Dateconverted
				 ORDER BY
					location,dateconverted
					) row_num

From CovidSql.dbo.CovidDeaths
)
Select *
From RowNumCTE
Where row_num > 1
Order by dateconverted

-------------------------------------------------------------------------------------------------------
-- Exploratory Data Analysis 


--Count the number of Rows per table
SELECT COUNT(*) as Num_Rows FROM CovidDeaths;
SELECT COUNT(*) as Num_Rows FROM CovidVaccinations;

-- Query To Show All the possible Countries

SELECT DISTINCT(Location)
FROM CovidDeaths
WHERE continent is not null
ORDER BY Location;

-- Query To Show All the possible Continents

SELECT DISTINCT(Continent)
FROM CovidDeaths
WHERE continent is not null;


-- Selecting the columns I am going to be Focusing on

SELECT Location,DateConverted, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent is not null 
ORDER BY Location, DateConverted;


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country (DeathPercentage)
-- Changed total_death data type from nvarchar to float to be able to perfrom an aggregate function
-- Changed total_cases with to a float value  

SELECT location, dateConverted, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
FROM CovidDeaths
ORDER BY Location, dateConverted;


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid (PercnetPopulationInfected)
-- Created an aggergate function by dividing total_cases and population

SELECT Location, dateConverted, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
FROM CovidDeaths
WHERE continent is not null
and location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
ORDER BY Location, dateConverted;

-- Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
FROM CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc;




--Highest death count
--1 Countries with Highest Death Count per Population
SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null 
GROUP BY Location
ORDER BY TotalDeathCount desc;

-- 2Continents With The Highest Death Count Per Population
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
Group by location
order by TotalDeathCount desc;

-- 3
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null 
order by 1,2


--4
-- Show the top 10 countries with the highest Percent of population infected
SELECT TOP 10 Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population)) as PercentPopulationInfected
FROM CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc;



--5
-- Total Vaccinations per Continent
Select location, SUM(Cast(new_vaccinations as bigint)) as TotalVaccinations
FROM CovidVaccinations
Where continent is null 
and location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
Group by location
order by TotalVaccinations desc;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccin
SELECT dea.Location,dea.DateConverted, dea.population,
SUM(cast(vac.new_vaccinations as int)) as TotalVaccination,SUM(cast(dea.new_deaths as int)) as TotalDeathCount
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac ON dea.location = vac.location and dea.DateConverted = vac.DateConverted
WHERE dea.continent is not null
GROUP BY dea.Location,dea.DateConverted, dea.population
ORDER BY TotalVaccination desc,TotalDeathCount desc

-- population vs new vaccinations
SELECT dea.Location,dea.DateConverted, dea.population,vac.new_vaccinations
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac ON dea.location = vac.location and dea.DateConverted = vac.DateConverted
WHERE dea.continent is not null
ORDER BY dea.DateConverted,dea.population











































-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.Location,dea.Date, dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac 
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 




-- queries Used For Creating Visualizations In Power BI --------------------------------------------------

-- 1 
--Continents With The Highest Death Count Per Population
SELECT Location, SUM(cast(new_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is null 
and location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
GROUP BY Location
ORDER BY TotalDeathCount desc;

-- 2 Global Numbers
-- Showing the Total Cases, Total Deaths, and The Overall DeathPercentage
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null 
ORDER BY total_cases,total_deaths;

-- 3



--4

