select * 
from Portfolioprojectoncovid..CovidDeaths
order by 3,4

--Select *
--from Portfolioprojectoncovid..Covidvaccination
--order by 3,4

Select location, date, total_cases,new_cases,total_deaths,population
from Portfolioprojectoncovid..CovidDeaths
order by 1,2

Select location, date , total_cases,total_deaths,( total_deaths/total_cases)*100 as DeathPercentage
from  Portfolioprojectoncovid..CovidDeaths
where location like '%India%'
order by 1,2

Select location, date , total_cases,population,( total_cases/population)*100 as Positivepercentage
from  Portfolioprojectoncovid..CovidDeaths
where location like '%India%'
order by 1,2


Select location,  Max( total_cases)as HighestInfectionCount,population,Max(( total_cases/population)*100) as Positivepercentage
from  Portfolioprojectoncovid..CovidDeaths
group by location,population
order by Positivepercentage Desc

Select location,Max(Cast(total_deaths as int)) as TotaldeathCount
from Portfolioprojectoncovid..CovidDeaths
where continent is not null
group by location
Order by TotaldeathCount Desc


Select location,Max(Cast(total_deaths as int)) as TotaldeathCount
from Portfolioprojectoncovid..CovidDeaths
where continent is  null
group by location
Order by TotaldeathCount Desc


Select date,Sum(new_cases) as Totalcases,Sum(Cast(new_deaths as int)) as TotalDeaths,Sum(Cast(new_deaths as int))/Sum(new_cases) *100 as DeathPercentage
From Portfolioprojectoncovid..CovidDeaths
where continent is not null
group by date
order by 1,2

Select Sum(new_cases) as Totalcases,Sum(Cast(new_deaths as int)) as TotalDeaths,Sum(Cast(new_deaths as int))/Sum(new_cases) *100 as DeathPercentage
From Portfolioprojectoncovid..CovidDeaths
where continent is not null
order by 1,2


Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations, Sum(Convert(int,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
from Portfolioprojectoncovid..CovidDeaths dea
Join Portfolioprojectoncovid..Covidvaccination vac
         on dea.location=vac.location
		 and   dea.date= vac.date
where dea.continent is not null
order by 2,3


with PopvsVac (continent, location, date,population, new_vaccination, RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations, Sum(Convert(int,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
from Portfolioprojectoncovid..CovidDeaths dea
Join Portfolioprojectoncovid..Covidvaccination vac
         on dea.location=vac.location
		 and   dea.date= vac.date
where dea.continent is not null
)
Select * ,(RollingPeopleVaccinated/population)*100 
from PopvsVac




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
From Portfolioprojectoncovid..CovidDeaths dea
Join Portfolioprojectoncovid..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



Create View PercentVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Portfolioprojectoncovid..CovidDeaths dea
Join Portfolioprojectoncovid..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null