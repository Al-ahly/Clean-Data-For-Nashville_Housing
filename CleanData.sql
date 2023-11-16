--Cleaning Data 

Select *
From dbo.Nashville_Housing


-- Format SaleDate

Select SaleDate , CONVERT(date,SaleDate)
From dbo.Nashville_Housing


ALTER TABLE Nashville_Housing
Add SaleDateConverted Date;

Update dbo.Nashville_Housing
SET SaleDateConverted = CONVERT(date,SaleDate)


Select SaleDateConverted
From Nashville_Housing

-- Delete Unused SaleDate Column 

ALTER TABLE dbo.Nashville_Housing
DROP COLUMN SaleDate



---- Populate Property Address data That Have null Data

Select *
From Nashville_Housing
--Where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) AS Val_Is_Null
From Nashville_Housing AS a
JOIN Nashville_Housing AS b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID 
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Nashville_Housing AS a
JOIN Nashville_Housing AS b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID 
Where a.PropertyAddress is null



--Break PropertyAddress into Columns (Address, City)

Select PropertyAddress
From Nashville_Housing



SELECT
    LEFT(PropertyAddress, CHARINDEX(',', PropertyAddress) - 1) AS Address,
    RIGHT(PropertyAddress, LEN(PropertyAddress) - CHARINDEX(',', PropertyAddress)) AS Address
FROM Nashville_Housing

--Split Address

ALTER TABLE Nashville_Housing
Add PropertySplitAddress Nvarchar(255);

Update Nashville_Housing
SET PropertySplitAddress = LEFT(PropertyAddress, CHARINDEX(',', PropertyAddress) - 1) 

--Split City

ALTER TABLE Nashville_Housing
Add PropertySplitCity Nvarchar(255);

Update Nashville_Housing
SET PropertySplitCity = RIGHT(PropertyAddress, LEN(PropertyAddress) - CHARINDEX(',', PropertyAddress))


--Delete PropertyAddress

ALTER TABLE Nashville_Housing
DROP COLUMN PropertyAddress


--Break OwnerAddress into Columns (Address, City,State)

Select OwnerAddress
From Nashville_Housing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) AS Address
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) AS City
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) AS State
From Nashville_Housing


--Split Address

ALTER TABLE Nashville_Housing
Add OwnerSplitAddress Nvarchar(255);

Update Nashville_Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) 


--Split City

ALTER TABLE Nashville_Housing
Add OwnerSplitCity Nvarchar(255);

Update Nashville_Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


--Split State

ALTER TABLE Nashville_Housing
Add OwnerSplitState Nvarchar(255);

Update Nashville_Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


--Delete OwnerAddress

ALTER TABLE Nashville_Housing
DROP COLUMN OwnerAddress




-- Change Y to Yes and N to No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Nashville_Housing
Group by SoldAsVacant
order by SoldAsVacant


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From Nashville_Housing


Update Nashville_Housing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END




--Remove Rows Duplication


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 SalePrice,
				 SaleDateConverted,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Nashville_Housing
)
--Delete 
Select *
From RowNumCTE
Where row_num > 1
order by ParcelID


--Data After Cleaning

Select *
From Nashville_Housing 



