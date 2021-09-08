USE [PortfolioProject 2]
SELECT * FROM HOUSING_DATAS

--Standardize Date Format--
ALTER TABLE HOUSING_DATAS
ADD SalesDate DATE
UPDATE HOUSING_DATAS
SET SalesDate = CONVERT(DATE,SaleDate) 

--Populate Poperty Address data--
SELECT * FROM HOUSING_DATAS
WHERE PropertyAddress IS NULL
SELECT * FROM HOUSING_DATAS
ORDER BY ParcelID
SELECT A.PropertyAddress,A.ParcelID,B.PropertyAddress,B.ParcelID,ISNULL(A.PropertyAddress,B.PropertyAddress) 
FROM  HOUSING_DATAS A JOIN HOUSING_DATAS B
ON A.ParcelID = B.ParcelID AND A.UniqueID<>B.UniqueID 
WHERE A.PropertyAddress IS NULL
UPDATE A
SET PropertyAddress=ISNULL( A.PropertyAddress,B.PropertyAddress)
FROM HOUSING_DATAS A JOIN HOUSING_DATAS B
ON A.ParcelID = B.ParcelID AND A.UniqueID<>B.UniqueID 
WHERE A.PropertyAddress IS NULL

 ----Breaking out Address into Individual Columns--
 
 ALTER TABLE HOUSING_DATAS
 ADD House_Address NVARCHAR(255)
 UPDATE HOUSING_DATAS
 SET House_Address=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)
 ALTER TABLE HOUSING_DATAS
 ADD City_Address NVARCHAR(255)
 UPDATE HOUSING_DATAS
 SET City_Address=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)-CHARINDEX(',',PropertyAddress)) 

 ALTER TABLE HOUSING_DATAS
 ADD Owner_Address NVARCHAR(255)
 UPDATE HOUSING_DATAS
 SET Owner_Address=PARSENAME(REPLACE(OwnerAddress,',','.'),3)
 ALTER TABLE HOUSING_DATAS
 ADD Owner_City NVARCHAR(255)
 UPDATE HOUSING_DATAS
 SET Owner_City=PARSENAME(REPLACE(OwnerAddress,',','.'),2)
 ALTER TABLE HOUSING_DATAS
 ADD Owner_State NVARCHAR(255)
 UPDATE HOUSING_DATAS
 SET Owner_State=PARSENAME(REPLACE(OwnerAddress,',','.'),1)

 --Changing Y & N to Yes & No in 'Sold as Vacant' field--
 SELECT SoldAsVacant,COUNT(SoldAsVacant ) AS Count
 FROM HOUSING_DATAS
 GROUP BY SoldAsVacant

 UPDATE HOUSING_DATAS
 SET SoldAsVacant = CASE 
 WHEN SoldAsVacant = 'Y' THEN 'YES'
 WHEN SoldAsVacant = 'N' THEN 'No'
 ELSE SoldAsVacant 
 END

 --Remove Duplicates--
 WITH RowCTE AS
 (
 SELECT *,ROW_NUMBER() OVER (PARTITION BY PropertyAddress,ParcelID,LegalReference,SalesDate ORDER BY UniqueID) AS Row 
 FROM HOUSING_DATAS
 )
 --SELECT * FROM  RowCTE WHERE Row>1 ORDER BY 4

 DELETE FROM  RowCTE
 WHERE Row>1

 --Delete unused columns--
 ALTER TABLE HOUSING_DATAS
 DROP COLUMN SaleDate,PropertyAddress