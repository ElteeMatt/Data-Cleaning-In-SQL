

/*

Cleaning Data in SQL Queries


*/

Use PortfolioProject

Select *
from PortfolioProject.dbo.NashvilleHousing;

----------------------------------------------------------------------------------------------------------------------------------------------

----Standardize Date Format

Select SaleDate, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(Date,SaleDate)



ALTER  TABLE NashvilleHousing
ADD SaleDateConverted Date;



Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)



Select  SaleDateConverted, CONVERT(Date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing;


-----------------------------------------------------------------------------------------------------------------------------------------------------

---Populate Property Address data



Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
Where PropertyAddress is null


Select * 
From PortfolioProject.dbo.NashvilleHousing
order by ParcelID





select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing A
JOIN PortfolioProject.dbo.NashvilleHousing B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is null


UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing A
JOIN PortfolioProject.dbo.NashvilleHousing B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is null




------------------------------------------------------------------------------------------------------------------------------------------------

		----Breaking out Address  into individual columns (Address, City, State)
		----We are going to use SUB-STRINGS, SPLIT STRING CHARINDEX, CROSS APPLY & PIVOT


Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
Order BY PropertyAddress desc



SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address

From PortfolioProject.dbo.NashvilleHousing

--------Create Two Seperate Tables---

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVarchar(255);


UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -2)


ALTER TABLE NashvilleHousing 
Add PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))
	


Select *
From PortfolioProject.dbo.NashvilleHousing



---------------------------------------------------------------------------------------------------------------

use PortfolioProject

Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing
Order by OwnerAddress desc


Select UniqueID, ISNULL(Address1,'') as Address, ISNULL(Address2,'') as City, ISNULL(Address3,'') as State
From (
Select UniqueID, OwnerAddress,'Address'+ CAST( ROW_NUMBER()OVER (PARTITION BY UniqueID ORDER BY UniqueID) as VARCHAR) Col, Split.value 
From PortfolioProject.dbo.NashvilleHousing AS OAS
Cross Apply String_split(OwnerAddress,',') as split) as tbl
Pivot (Max(value) for col in (Address1,Address2,Address3)) as pvt



ALTER TABLE NashvilleHousing 
Add Address Nvarchar(255),
City Nvarchar (255),
State nvarchar(255);



UPDATE NashvilleHousing
SET Address = tbl.Address1,
    City = tbl.Address2,
    State = tbl.Address3
FROM (
    SELECT UniqueID, 
           ISNULL(Address1,'') AS Address1, 
           ISNULL(Address2,'') AS Address2, 
           ISNULL(Address3,'') AS Address3
    FROM (
        SELECT UniqueID, 
               OwnerAddress,
               'Address' + CAST(ROW_NUMBER() OVER (PARTITION BY UniqueID ORDER BY UniqueID) AS VARCHAR) AS Col, 
               Split.value AS value
        FROM PortfolioProject.dbo.NashvilleHousing AS OAS
        CROSS APPLY STRING_SPLIT(OwnerAddress,',') AS Split
    ) AS tbl
    PIVOT (
        MAX(tbl.value) FOR tbl.Col IN (Address1, Address2, Address3)
    ) AS pvt
) AS tbl
WHERE NashvilleHousing.UniqueID = tbl.UniqueID



------Rename Split columns and Drop some columns------

Alter Table NashvilleHousing
DROP COLUMN OwnerAddress


Alter Table NashvilleHousing
DROP COLUMN SaleDate

Alter Table NashvilleHousing
DROP COLUMN PropertyAddress

Alter Table NashvilleHousing
DROP COLUMN TaxDistrict


Select *
From PortfolioProject.dbo.NashvilleHousing



--------------------------------------------------------------------------------------------------------------
---Change 'Y' & 'N' to 'Yes' & 'No'

Select Distinct(SoldAsVacant),COUNT(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' then 'Yes'
		 WHEN SoldAsVacant = 'N' then 'No'
	ELSE SoldAsVacant
	END
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' then 'Yes'
		 WHEN SoldAsVacant = 'N' then 'No'
	ELSE SoldAsVacant
	END





-------------------------------------------------------------------------------------------------------------------------------------------
	----Remove Duplicates---


WITH RownumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 SalePrice,
				 SaleDateConverted,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
)
SELECT *
From RownumCTE
Where row_num > 1
order by PropertySplitAddress




---------------------------------------------- END -----------------------------------------------