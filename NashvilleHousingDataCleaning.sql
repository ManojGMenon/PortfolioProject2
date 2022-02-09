/*

CLEANING DATA IN SQL QUERIES

*/


Select *
From PortfolioProject2_Nashville.dbo.NashvilleHousing
-------------------------------------------------------------------------

-- Standardize Date Format
--     Use ALTER TABLE and UPDATE functions in SQL


Select SaleDate, Convert(Date, SaleDate) as OnlyDate
From PortfolioProject2_Nashville.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
Set SaleDateConverted = Convert(Date,SaleDate)

Select SaleDateConverted
From PortfolioProject2_Nashville.dbo.NashvilleHousing



----------------------------------------------------------------------------

-- Populate Property Address data where it is absent
--     Use ISNULL to substitute an empty cell with alternate data
--      Use a self JOIN

Select *
From PortfolioProject2_Nashville.dbo.NashvilleHousing
-- Where PropertyAddress is NULL
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
--Select *
From PortfolioProject2_Nashville.dbo.NashvilleHousing a
JOIN PortfolioProject2_Nashville.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress Is NULL

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject2_Nashville.dbo.NashvilleHousing a
JOIN PortfolioProject2_Nashville.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress Is NULL


---------------------------------------------------------------------------

-- Breaking out PropertyAddress into Individual columns (Address, City, State)	
--    Use SUBSTRING and CHARINDEX to search for the comma delimiter

Select PropertyAddress
From PortfolioProject2_Nashville.dbo.NashvilleHousing

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
From PortfolioProject2_Nashville.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter Table NashvilleHousing
Add PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select *
From PortfolioProject2_Nashville.dbo.NashvilleHousing



---------------------------------------------------------------------------

-- Breaking out OwnerAddress into Individual columns (Address, City, State)	
--    Use PARSENAME and CHARINDEX to search for the comma delimiter
--      (easier than using SUBSTRING  and  CHARINDEX)

Select OwnerAddress
From PortfolioProject2_Nashville.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject2_Nashville.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Alter Table NashvilleHousing
Add OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Alter Table NashvilleHousing
Add OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

Select *
From PortfolioProject2_Nashville.dbo.NashvilleHousing



----------------------------------------------------------------------------

-- Change Y and N to Yes and No in the 'Sold as Vacant' field
--    Use 'CASE WHEN THEN END' 


Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject2_Nashville.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
	CASE When SoldAsVacant = 'Y' Then 'Yes'
	     When SoldAsVacant = 'N' Then 'No'
		 Else SoldAsVacant
		 END
From PortfolioProject2_Nashville.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	     When SoldAsVacant = 'N' Then 'No'
		 Else SoldAsVacant
		 END

		 		 

----------------------------------------------------------------------------

-- Remove Duplicates
--    Use CTEs, ROW_NUMBER and PARTITION OVER functions

WITH RowNumCTE AS(
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
From PortfolioProject2_Nashville.dbo.NashvilleHousing
--Order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



-----------------------------------------------------------------------

-- Delete Unused columns


Select *
From PortfolioProject2_Nashville.dbo.NashvilleHousing

Alter Table PortfolioProject2_Nashville.dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table PortfolioProject2_Nashville.dbo.NashvilleHousing
Drop Column SaleDate