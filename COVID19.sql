/*
Covid-19 Project - Data Exploration
*/


-- An overview of the dataset
Select * from COVID19..CovidDeaths;
Select * from COVID19..CovidVaccinations;


-- Main figures to analyze
Select dea.continent, dea.Location, dea.date, dea.total_cases, dea.new_cases, dea.total_deaths, dea.population,
		vac.new_vaccinations, vac.people_vaccinated, vac.people_fully_vaccinated
From COVID19..CovidDeaths dea
Join COVID19..CovidVaccinations vac
On dea.location = vac.location 
and dea.date = vac.date
order by 1,2;

-- Change data type of columns for later calculations
Alter table COVID19..CovidDeaths
Alter column total_deaths float;

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From COVID19..CovidDeaths
where continent is not null 
order by 1,2;

-- Summarize Total Cases, Total Deaths & Death Percentage (likelihood of dying if contracted with covid-19) by each country and order by Death Percentage from highest to lowest

Select location, max(total_cases) as TotalCases, max(total_deaths) as TotalDeaths, (max(total_deaths)/max(total_cases))*100 as DeathPercentage
From COVID19..CovidDeaths
group by location
order by 4 desc;


-- Summarize Total Cases vs Population to show what percentage of population infected with Covid

Select Location, max(Population) as Population, max(total_cases) as TotalCases,  (max(total_cases)/max(population))*100 as PercentPopulationInfected
From COVID19..CovidDeaths
group by location
order by 1,2;


-- Select Top 10 Countries with Highest Infection Rate compared to Population

Select Top 10 Location, Population, max(total_cases) as HighestInfectionCount,  max((total_cases/population))*100 as PercentPopulationInfected
From COVID19..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc;


-- Select Top 10 Countries with Highest Death rate per Population

Select Top 10 Location, MAX((Total_deaths/population)*100) as DeathRate
From COVID19..CovidDeaths 
Group by Location
order by DeathRate desc;


-- SUMMARIZE BY CONTINENT

-- Rank the contintents by Number of Death cases per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From COVID19..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc;


-- Show the Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From COVID19..CovidDeaths dea
Join COVID19..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3;


-- Using CTE to perform Calculation on Partition By in previous query

With Fully_vaccinated as(
Select vac.continent, vac.Location, dea.population, max(CONVERT(int,vac.people_fully_vaccinated)) as people_fully_vaccinated
From COVID19..CovidDeaths dea
Join COVID19..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
group by vac.continent, vac.location, dea.population)
Select continent, sum(people_fully_vaccinated) as people_fully_vaccinated
From Fully_vaccinated
Group by continent
Order by 1;


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From COVID19..CovidDeaths dea
Join COVID19..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
