
--Covid 19 Data Explorqation

--Skills used : Joins, CTE's , Temp Tables, Windows Functions , Aggregate functions, Creating views, Converting data types

select location, date, total_cases,new_cases,total_deaths,population
from PortfolioProject..coviddeaths
where continent is not null
order by 1,2


--Selecting data that we are going to start with
select location, date, total_cases,new_cases,total_deaths,population
from PortfolioProject..coviddeaths
where continent is not null
order by 1,2


--total cases vs total deaths
--shows likelihood of death in selected country

select location, date, total_cases,new_cases,total_deaths,(total_deaths/total_cases) *100 as deathpercentage
from PortfolioProject..coviddeaths
where location like '%india%' and continent is not null
order by 1,2


--total cases vs total population
--shows infection rate by population

select location, date, population, total_cases,(total_cases/population)*100 as afftectedpopulationper
from PortfolioProject..coviddeaths
--where location like '%india%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

select location,population, max(total_cases) as highestinfected, Max((total_cases/population))*100 as afftectedpopulationper
from PortfolioProject..coviddeaths
where continent is not null
group by location,population
order by afftectedpopulationper desc


-- Countries with Highest Death Count per Population

select location,max(cast(total_deaths as float)) as totaldeathcount 
from PortfolioProject..coviddeaths
where continent is not null
group by location
order by totaldeathcount desc


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

select continent,max(cast(total_deaths as float)) as totaldeathcount
from PortfolioProject..coviddeaths
where continent is not null
group by continent
order by totaldeathcount desc

-- GLOBAL NUMBERS

select SUM(new_cases) as gbl_tcases, SUM(cast(new_deaths as float)) as gbl_tdeaths, SUM(cast(new_deaths as float))/SUM(new_cases) * 100 as gbl_deathper
from PortfolioProject..coviddeaths
where continent is not null
--group by date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select cd.continent,cd.location, cd.date,cd.population,cv.new_vaccinations,
sum(convert (float,cv.new_vaccinations)) over (partition by cd.location order by cd.location,cd.date) as 
rollingpplvc
from PortfolioProject..coviddeaths as cd
join PortfolioProject..covidvaccinations as cv
on cd.location=cv.location
and cd.date=cv.date
where cd.continent is not null
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac ( Continent,location,date,population,new_vaccinations,rollingpplvc) 
as
(
select cd.continent,cd.location, cd.date,cd.population,cv.new_vaccinations,
sum(convert (float,cv.new_vaccinations)) over (partition by cd.location order by cd.location,cd.date) as 
rollingpplvc
from PortfolioProject..coviddeaths as cd
join PortfolioProject..covidvaccinations as cv
on cd.location=cv.location
and cd.date=cv.date
where cd.continent is not null
)
select *, convert(float,rollingpplvc/population)*100 as rollingpplvcper
from PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

drop table if exists #perpopvaxed 
create table #perpopvaxed
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpplvc numeric
)

Insert into #perpopvaxed

select cd.continent,cd.location, cd.date,cd.population,cv.new_vaccinations,
sum(convert (float,cv.new_vaccinations)) over (partition by cd.location order by cd.location,cd.date) as 
rollingpplvc
from PortfolioProject..coviddeaths as cd
join PortfolioProject..covidvaccinations as cv
on cd.location=cv.location
and cd.date=cv.date
where cd.continent is not null

select *, convert(float,rollingpplvc/population)*100 as rollingpplvcper
from #perpopvaxed


-- Creating View to store data for later visualizations

create view perpopvaxed as

select cd.continent,cd.location, cd.date,cd.population,cv.new_vaccinations,
sum(convert (float,cv.new_vaccinations)) over (partition by cd.location order by cd.location,cd.date) as 
rollingpplvc
from PortfolioProject..coviddeaths as cd
join PortfolioProject..covidvaccinations as cv
on cd.location=cv.location
and cd.date=cv.date
where cd.continent is not null

select * from perpopvaxed