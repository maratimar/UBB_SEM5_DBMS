USE ParcAutoBun
GO

CREATE TABLE Clienti1(

id_client INT PRIMARY KEY IDENTITY(1,1),
nume VARCHAR(30),
oras VARCHAR(30)
);
GO

CREATE TABLE Piese1(

id_piesa INT PRIMARY KEY IDENTITY(1,1),
denumire VARCHAR(30),
pret INT
);
GO

CREATE TABLE Bon_fiscal_piese1(

id_bon INT PRIMARY KEY IDENTITY(1,1),
id_client INT FOREIGN KEY REFERENCES Clienti1(id_client),
id_piesa INT FOREIGN KEY REFERENCES Piese1(id_piesa)
);

CREATE FUNCTION ufValidateNume (@name VARCHAR(30))
RETURNS INT
AS
BEGIN
	DECLARE @return INT
	SET @return=1
	IF (@name IS NULL OR LEN(@name)<2)
	BEGIN
		SET @return=0
	END
	RETURN @return
END
GO

CREATE PROCEDURE uspAddClienti (@name VARCHAR(30), @oras VARCHAR(30))
AS
	SET NOCOUNT ON
	IF (dbo.ufValidateName(@name) <> 1)
	BEGIN
		RAISERROR('Name is invalid',14,1)
	END
	IF (dbo.ufValidateOras(@oras) <> 1)
	BEGIN
		RAISERROR('Oras is invalid',14,1)
	END
	INSERT INTO Clienti1 (nume,oras) VALUES (@name, @oras)
	INSERT INTO LogTable VALUES('add','client',GETDATE())
GO

CREATE PROCEDURE uspAddPiese (@denumire VARCHAR(30), @pret INT)
AS
	SET NOCOUNT ON
	IF (dbo.ufValidateName(@denumire) <> 1)
	BEGIN
		RAISERROR('Name is invalid',14,1)
	END
	IF (dbo.ufValidatePrice(@pret) <> 1)
	BEGIN
		RAISERROR('Pret is invalid',14,1)
	END
	INSERT INTO Piese1 (denumire,pret) VALUES (@denumire, @pret)
	INSERT INTO LogTable VALUES('add','piesa',GETDATE())
GO

CREATE PROCEDURE uspAddBon (@client INT,@piesa INT)
AS
	SET NOCOUNT ON
	IF NOT EXISTS (SELECT * FROM Clienti1 WHERE id_client = @client)
	BEGIN
		RAISERROR('Invalid client',14,1)
	END
	IF NOT EXISTS (SELECT * FROM Piese1 WHERE id_piesa = @piesa)
	BEGIN
		RAISERROR('Invalid piesa',14,1)
	END
	IF EXISTS (SELECT * FROM Bon_fiscal_piese1 WHERE id_client = @client AND id_piesa = @piesa)
	BEGIN
		RAISERROR('Pair already exists',14,1)
	END
	INSERT INTO Bon_fiscal_piese1 VALUES (@client, @piesa)
	INSERT INTO LogTable VALUES('add','bon',GETDATE())
GO

CREATE PROCEDURE uspAddCommitScenario
AS
	BEGIN TRAN
	BEGIN TRY
		EXEC uspAddClienti 'Timar Mara','Cluj-Napoca'
		EXEC uspAddPiese 'bujie',200
		EXEC uspAddBon 1,1
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		RETURN
	END CATCH
GO

CREATE PROCEDURE uspAddRollbackScenario
AS
	BEGIN TRAN
	BEGIN TRY
		EXEC uspAddClienti 'Timar Mara','Cluj-Napoca'
		EXEC uspAddPiese 'b',200   --fail din cauza validarilor
		EXEC uspAddBon 1,1
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		RETURN
	END CATCH
GO

EXEC uspAddCommitScenario
EXEC uspAddRollbackScenario
SELECT * FROM LogTable
SELECT * FROM Clienti1
SELECT * FROM Piese1
SELECT * FROM Bon_fiscal_piese1

DELETE FROM Clienti1
DELETE FROM Piese1
DELETE FROM Bon_fiscal_piese1

GO


--partea 2 din tema
ALTER PROCEDURE uspAddClientiRecover (@name VARCHAR(30), @oras VARCHAR(30))
AS
	SET NOCOUNT ON
	BEGIN TRAN
	BEGIN TRY
		IF (dbo.ufValidateNume(@name) <> 1)
		BEGIN
			RAISERROR('Name is invalid',14,1)
		END
		IF (dbo.ufValidateOras(@oras) <> 1)
		BEGIN
			RAISERROR('Oras is invalid',14,1)
		END
		IF EXISTS (SELECT * FROM Clienti1 WHERE nume = @name and oras=@oras)
		BEGIN
			RAISERROR('Client already exists',14,1)
		END
		INSERT INTO Clienti1 VALUES (@name,@oras)
		INSERT INTO LogTable VALUES('add','client',GETDATE())
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
	END CATCH
GO

ALTER PROCEDURE uspAddPieseRecover (@denumire VARCHAR(30), @pret INT)
AS
	SET NOCOUNT ON
	BEGIN TRAN
	BEGIN TRY
	 IF (dbo.ufValidateName(@denumire) <> 1)
	 BEGIN
		RAISERROR('Name is invalid',14,1)
	 END
	 IF (dbo.ufValidatePrice(@pret) <> 1)
	 BEGIN
		RAISERROR('Pret is invalid',14,1)
	 END
	 IF EXISTS (SELECT * FROM Piese1 WHERE denumire = @denumire and pret=@pret)
		BEGIN
			RAISERROR('Piesa already exists',14,1)
		END
		INSERT INTO Piese1 VALUES (@denumire,@pret)
		INSERT INTO LogTable VALUES('add','piesa',GETDATE())
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
	END CATCH
GO

ALTER PROCEDURE uspAddBonRecover (@client INT,@piesa INT)
AS
	SET NOCOUNT ON
	BEGIN TRAN
	BEGIN TRY
	  IF NOT EXISTS (SELECT * FROM Clienti1 WHERE id_client = @client)
	  BEGIN
		RAISERROR('Invalid client',14,1)
	  END
	  IF NOT EXISTS (SELECT * FROM Piese1 WHERE id_piesa = @piesa)
	  BEGIN
		RAISERROR('Invalid piesa',14,1)
	  END
	  IF EXISTS (SELECT * FROM Bon_fiscal_piese1 WHERE id_client = @client AND id_piesa = @piesa)
	  BEGIN
		RAISERROR('Pair already exists',14,1)
	  END
	INSERT INTO Bon_fiscal_piese1 VALUES (@client, @piesa)
	INSERT INTO LogTable VALUES('add','bon',GETDATE())
	COMMIT TRAN
  END TRY
	BEGIN CATCH
		ROLLBACK TRAN
	END CATCH
GO

ALTER PROCEDURE uspBadAddScenario
AS
	EXEC uspAddClientiRecover 'Timar Mara','Cluj-Napoca'
	EXEC uspAddPieseRecover 'b',200   --fail din cauza validarilor
    EXEC uspAddBonRecover 6,5
GO

ALTER PROCEDURE uspGoodAddScenario
AS
	EXEC uspAddClientiRecover 'Timar Mara','Cluj-Napoca'
	EXEC uspAddPieseRecover 'bujie',200   
    EXEC uspAddBonRecover 8,6
GO

EXEC uspBadAddScenario
SELECT * FROM LogTable

EXEC uspGoodAddScenario
SELECT * FROM LogTable

SELECT * FROM Clienti1
SELECT * FROM Piese1
SELECT * FROM Bon_fiscal_piese1

DELETE FROM Clienti1
DELETE FROM Piese1
DELETE FROM Bon_fiscal_piese1














