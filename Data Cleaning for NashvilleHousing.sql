/*
Cleaning Data in SQL Queries
*/


Select *
From Data_cleaning_project.dbo.nashvillehousing;
--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select saleDate, CONVERT(Date,SaleDate)
From Data_cleaning_project.dbo.nashvillehousing;

UPDATE nashvillehousing
SET saleDate = CONVERT(DATE,saleDate);

--Another way to update it:

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate);
 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From Data_cleaning_project.dbo.nashvillehousing
--Where PropertyAddress is null
order by ParcelID;

--Unfortunately there is null values in the property address, We can get this data from self joining the table as for each unique
--parce ID the propert address is the same.

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From Data_cleaning_project.dbo.nashvillehousing a
JOIN Data_cleaning_project.dbo.nashvillehousing b
	ON  a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null;

-- When using self join afte update instead of the table name use the abbreviation you set in this example (a) as otherwise it gives error. 
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Data_cleaning_project.dbo.nashvillehousing a
JOIN Data_cleaning_project.dbo.nashvillehousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null;

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From Data_cleaning_project.dbo.nashvillehousing;

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as split_city

From Data_cleaning_project.dbo.nashvillehousing;

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 );


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress));




Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing;


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From Data_cleaning_project.dbo.nashvillehousing;



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3);


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2);



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1);



Select *
From Data_cleaning_project.dbo.nashvillehousing;

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Data_cleaning_project.dbo.nashvillehousing
Group by SoldAsVacant
order by 2;




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From Data_cleaning_project.dbo.nashvillehousing;


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END;






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE 
AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Data_cleaning_project.dbo.nashvillehousing
)
DELETE
From RowNumCTE
Where row_num > 1;




Select *
From Data_cleaning_project.dbo.nashvillehousing

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From Data_cleaning_project.dbo.nashvillehousing


ALTER TABLE Data_cleaning_project.dbo.nashvillehousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate