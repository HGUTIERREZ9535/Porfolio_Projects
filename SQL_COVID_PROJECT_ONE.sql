select * from PortFolioProject..CovidDeaths$
order by 3,4


--Select data that we are going to use
select location,date, total_cases, new_cases,total_deaths,population from PortFolioProject..CovidDeaths$
order by 1,2

--Percentage of deaths based on  total cases 
select location,date, (total_cases), (total_deaths), (total_deaths/ total_cases)*100 as deathpertentage from PortFolioProject..CovidDeaths$
order by 1,2

--Total cases inside the  Population 
select location,date, total_cases,population,(total_cases/population)*100 as totalcaseperpopulation from PortFolioProject..CovidDeaths$
order by 1,2

--Countries with highest infections rates compare to population
select location, MAX (total_cases) as highestinfectionsrates, max(total_cases/population)*100 as Percentagepopulationinfected ,population from PortFolioProject..CovidDeaths$
GROUP BY location, population 
order by Percentagepopulationinfected desc

--Countries with highest deaths rates compare to population 
-- Use Cast since total_deaths is an nvarchar value
-- When continent is null give us the continent as location 
select location, MAX (cast(total_deaths as int)) as highesdeathsrates, max(total_deaths/population)*100 as Percentagepopulationdeaths ,population from PortFolioProject..CovidDeaths$
where continent is not null 
GROUP BY location, population 
order by highesdeathsrates  desc

-- Countries with highest deaths rates 
select location, MAX (cast(total_deaths as int)) as highesdeathsrates from PortFolioProject..CovidDeaths$
 where continent is not null
GROUP BY location  
order by highesdeathsrates  desc

-- Continents with highest deaths rates 
select location, MAX (cast(total_deaths as int)) as highesdeathsrates from PortFolioProject..CovidDeaths$
 where continent is  null
GROUP BY location 
order by highesdeathsrates  desc

--Global numbers 
--First case VS first death
select date, sum(new_cases) as new_cases, sum(cast (new_deaths as int )) as new_deaths, (sum(cast (new_deaths as int ))/sum(new_cases))*100 as deathspercentage from PortFolioProject..CovidDeaths$
where continent is not null
group by date
order by 1,2

--Total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortFolioProject..CovidDeaths$ dea
join PortFolioProject..CovidVaccinations$ vac
on dea.date = vac.date
and dea.location= vac.location 
where dea.continent is not null 
order by 1,2,3

--Partition function
--Rollingpeoplevaccinated, shows the add on people being vaccinated base on date and location 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
from PortFolioProject..CovidDeaths$ dea
join PortFolioProject..CovidVaccinations$ vac
on dea.date = vac.date
and dea.location= vac.location 
where dea.continent is not null 
order by 1,2,3

--CTE// we create the cte since we cant use a table we just create "Rollingpeoplevaccinated"
with vaccinatedvspopulation as 
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
from PortFolioProject..CovidDeaths$ dea
join PortFolioProject..CovidVaccinations$ vac
on dea.date = vac.date
and dea.location= vac.location 
where dea.continent is not null 
)
select *,( Rollingpeoplevaccinated/population)*100 as percentagepeoplevaccinated from Vaccinatedvspopulation
order by 1,2

--Creating view to store data for later Visualizations
CREATE VIEW PercentagePopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
from PortFolioProject..CovidDeaths$ dea
join PortFolioProject..CovidVaccinations$ vac
on dea.date = vac.date
and dea.location= vac.location 
where dea.continent is not null

 
 










