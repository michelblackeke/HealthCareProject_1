--HealthCare Project 1

/** This Project breakdown the medical conditions recorded in a healthcare dataset along with the total 
number of patients diagnosed with each condition. providing an insight intothe prevalence or frequency of varioushealth issues within
the dataset, retrieves a breakdown of medical conditions recorded in a healthcare dataset along with the total number of patients
diagnosed with each condition. It groups the data by distinct medical conditions, counting the occurrences of each condition across the dataset. 
This information helps identify the most prevalent insurance providers among the patient population, offering valuable data for resource allocation, 
understanding coverage preferences, and potentially indicating trends in healthcare accessibility based on insurance networks
providing an insight into the prevalence or frequency of various health issues within the dataset
**/

Use Emade_dev

select *
from [dbo].[healthcare_dataset]

Select * into EmadeProd.dbo.healthcare_dataset
from Emade_dev.[dbo].[healthcare_dataset]


-- 1.  Counting Total Record in Healthcare data;
Select Count(*) as TotalRec
From Emade_dev.[dbo].[healthcare_dataset]

-- 2. Finding maximum age of patient admitted.Healthcare;
SeLECT *
From Emade_dev.[dbo].[healthcare_dataset]
WHERE AGE IN(
            SELECT TOP 1 AGE 
            From Emade_dev.[dbo].[healthcare_dataset]
            ORDER BY AGE DESC)

-- 3. Finding Average age of hospitalized patients.Healthcare;
SELECT *
FROM Emade_dev.[dbo].[healthcare_dataset]
WHERE AGE IN (
              SELECT avg(Age) AvgAgeHospitalizedPatients
              From Emade_dev.[dbo].[healthcare_dataset]
             )

--or 

SELECT round(avg(Age),0) AvgAgeHospitalizedPatients
From Emade_dev.[dbo].[healthcare_dataset]

-- 4. Calculating Patients Hospitalized Age-wise from Maximum to Minimum
SELECT  Age AS PatientsAge, count(*) HosiptalizedPatientAgeCount
From Emade_dev.[dbo].[healthcare_dataset]
group by  Age
ORDER BY AGE DESC


-- 5. Calculating Maximum Count of patients on basis of total patients hospitalized with respect to age.

SELECT AGE, COUNT([age]) AS HosiptalizedPatientAgeMaxCount
FROM Emade_dev.[dbo].[healthcare_dataset]
--WHERE AGE = 89
GROUP BY AGE
order by HosiptalizedPatientAgeMaxCount desc

-- 6. Ranking Age on the number of patients Hospitalized  

SELECT  AGE, COUNT(age) AS TotalPatients,
       DENSE_RANK() OVER (ORDER BY COUNT(Age) DESC, Age Desc) AS AgeRank
FROM Emade_dev.[dbo].[healthcare_dataset]
GROUP BY  AGE
Having Count(age) > Avg(age)

--Select top 1 conditions 

Select Top 1 Medical_Condition, Age, TotalPatients, AgeRank
From (SELECT Medical_Condition, AGE, COUNT(age) AS TotalPatients,
       DENSE_RANK() OVER (ORDER BY COUNT(Age) DESC, Age Desc) AS AgeRank
FROM Emade_dev.[dbo].[healthcare_dataset]
GROUP BY  Medical_Condition, AGE
Having Count(age) > Avg(age)
) x

--or
Select Medical_Condition, Age, TotalPatients, AgeRank
From (SELECT Medical_Condition, AGE, COUNT(age) AS TotalPatients,
       DENSE_RANK() OVER (ORDER BY COUNT(Age) DESC, Age Desc) AS AgeRank
FROM Emade_dev.[dbo].[healthcare_dataset]
GROUP BY  Medical_Condition, AGE
Having Count(age) > Avg(age)
) x
where AgeRank = 2

--7. Finding Count of Medical Condition of patients and lisitng it by maximum no of patients.

SELECT Medical_Condition, Count(Name) as TotalPatients
From Emade_dev.[dbo].[healthcare_dataset]
Group by Medical_Condition
Order By TotalPatients Desc

--8. Finding Rank & Maximum number of medicines recommended to patients based on Medical Condition pertaining to them.
SELECT Medical_Condition, Medication, COUNT(Medication) AS TotalMedicationRecommendedToPatients,
       DENSE_RANK() OVER (ORDER BY COUNT(Medication) DESC) AS MedicalConditionRank
FROM Emade_dev.[dbo].[healthcare_dataset]
GROUP BY  Medical_Condition, Medication
--Order By 1;

--Analytical Function or Window Function 
Select Age, [NAME], Medical_Condition,
      ROW_NUMBER() OVER (PARTITION BY AGE ORDER BY AGE DESC) AS RN,
	  RANK() OVER (PARTITION BY AGE ORDER BY AGE DESC) AS RNK,
	  DENSE_RANK() OVER ( PARTITION BY AGE ORDER BY AGE DESC) AS DRANK
FROM Emade_dev.[dbo].[healthcare_dataset]



-- Findings : This information helps identify the most prevalent insurance providers among the patient population, offering valuable
--data for resource allocation, understanding coverage preferences, and potentially indicating trends in healthcare accessibility based on 
--insurance networks

-- 9. Most preffered Insurance Provide  by Patients Hospatilized
Select top 1 Insurance_Provider, TotalPatient
From (
Select Insurance_Provider, Count(distinct name) TotalPatient
FROM Emade_dev.[dbo].[healthcare_dataset]
Group By Insurance_Provider
) a
Order By TotalPatient Desc

-- 10. Finding out most preffered Hospital
Select top 1 Hospital, TotalPatient
From (
Select Hospital, Count(name) TotalPatient
FROM Emade_dev.[dbo].[healthcare_dataset]
Group By Hospital
) a
Order By TotalPatient Desc

-- 11. Identifying Average Billing Amount by Medical Condition.
Select Medical_Condition, Avg(Billing_Amount) AvgBilling
FROM Emade_dev.[dbo].[healthcare_dataset]
Group by  Medical_Condition

-- 12. Finding Billing Amount of patients admitted and number of days spent in respective hospital.
Select 
  Hospital, 
  Sum(Billing_Amount) PatientBillingAmount,
  Sum(Datediff(Day, Date_of_Admission, Discharge_Date)) PatientsSpentDay
FROM Emade_dev.[dbo].[healthcare_dataset]
Group by Hospital
Order By PatientsSpentDay desc

--13. Finding Total number of days sepnt by patient in an hospital for given medical condition
Select 
  Medical_Condition, --name,
  count(Name) TotalAdmitedPatient,
  Sum(Datediff(Day, Date_of_Admission, Discharge_Date)) TotalDaySpent
FROM Emade_dev.[dbo].[healthcare_dataset]
Group by Medical_Condition
Order By TotalDaySpent desc

--14. Finding Hospitals which were successful in discharging patients after having test results as 'Normal' with count of days taken to get results to Normal
Select 
  Hospital, --name,
 Count(Name) Patient,
 Avg(Datediff(Day, Date_of_Admission, Discharge_Date)) TotalDaySpent
FROM Emade_dev.[dbo].[healthcare_dataset]
Where Test_Results like '%Normal%'
Group by Hospital
Order By TotalDaySpent ASC

-- 15. Calculate number of blood types of patients which lies between age 20 to 45
 Select Blood_Type,
 Count(age) PatientAge
 FROM Emade_dev.[dbo].[healthcare_dataset]
 Where Age between 20 and 45
 Group by Blood_Type
 Order By PatientAge desc

-- 16. Find how many of patient are Universal Blood Donor and Universal Blood reciever
 Select Blood_Type,
 Count(NAME) Patients
 FROM Emade_dev.[dbo].[healthcare_dataset]
 Where Blood_Type IN ('O-' , 'AB+')
 Group by Blood_Type
 Order By Patients desc

 --or

 SELECT Patients, Blood_Type, Donor_Reciver_Status
 From(
 Select Blood_Type,
 Count(NAME) Patients,
 Case 
 when Blood_Type like '%O-%' then 'Universal Blood Donor'
 when Blood_Type like '%AB+%' THEN 'Universal Blood reciever'
 ELSE ' '
 END Donor_Reciver_Status
 FROM Emade_dev.[dbo].[healthcare_dataset]
 Where Blood_Type IN ('O-' , 'AB+')
 Group by Blood_Type
) x
