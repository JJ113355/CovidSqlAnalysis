# Covid 19 Exploratory Data Analysis  


## The Summary of this Project
This project focuses on exploring and analyzing COVID-19 data to gain insights into the global impact of the pandemic. This analysis on specific topics such as total death count per continent, total vaccinations per continent, and countrys with the overall highest infection count. Tools used in this project include **Excel**, **Microsoft SQL Server**, and **Power BI**. The dataset I used in this project was obtained from [Our World in Data](https://ourworldindata.org/covid-deaths). The dataset provides information on COVID-19 deaths, vaccinations, infection rate,  and it was crucial for the analysis performed in this project.


## Contents
### Obtaining the Data
1. Visit the url [Our World in Data COVID-19 Deaths](https://ourworldindata.org/covid-deaths).
2. Navigate to the download section.
3. Download the dataset in Excel format.

Ater obtaining the excel file I decided to break the dataset into two seperate tables one for deaths and one for vaccinations.

### Storing the Data in SQL
The relational database management system (RDMS) I choose was *Microsoft SQL Server*.I used the import wizard to direcly import the two excel files into a database called *CovidSql*. 

### Cleaning the Data
Since the dataset was an officall dataset it was already pretty clean to begin with. In Microsoft SQL Server I performed taskes such as **removing duplicates**, changing **date formats** .The code for cleaning the data is in [Covid_SQL_Query.sql](https://github.com/JJ113355/CovidSqlAnalysis/blob/main/Query/Covid_SQL_Query.sql). 


### Analyzing the Data


### Data Visualization using Power BI
The final step of this project is to visualize the data. 

