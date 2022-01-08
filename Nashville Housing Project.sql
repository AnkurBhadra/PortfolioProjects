Select * 
From PortfolioProject.dbo.NashvilleHousing

--Standardize Date Format

Select SaleDateConverted, CONVERT (Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT (Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT (Date,SaleDate)

--Populate Property Address data


Select *
From PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.propertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL (a.propertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


---- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as address
, SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as address
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress NVARCHAR (255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity NVARCHAR (255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

Select * 
FROM PortfolioProject.dbo.NashvilleHousing



Select OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

Select
PARSENAME (REPLACE (OwnerAddress, ',','.'),3)
,PARSENAME (REPLACE (OwnerAddress, ',','.'),2)
,PARSENAME (REPLACE (OwnerAddress, ',','.'),1)
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress NVARCHAR (255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME (REPLACE (OwnerAddress, ',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity NVARCHAR (255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME (REPLACE (OwnerAddress, ',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState NVARCHAR (255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME (REPLACE (OwnerAddress, ',','.'),3)


---Change Y and N to Yes and No in SoldAsVacant field

Select Distinct(SoldAsVacant), Count (SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE	WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
		Else SoldAsVacant
		END
FROM PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE	WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
		Else SoldAsVacant
		END

--- Remove Duplicates

With RowNumCTE AS(
Select *,
	ROW_NUMBER () OVER (
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
				 UniqueID	
				 ) row_num

FROM PortfolioProject.dbo.NashvilleHousing
)
Select *
FROM RowNumCTE
WHERE row_num > 1


--Delete Unused Coloumns

Select *
From dbo.NashvilleHousing

ALTER TABLE  dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress,SaleDate

ALTER TABLE  dbo.NashvilleHousing
DROP COLUMN SaleDate
