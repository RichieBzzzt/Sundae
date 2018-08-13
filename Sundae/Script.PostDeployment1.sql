
IF NOT EXISTS (
		SELECT name
		FROM master.sys.server_principals
		WHERE name LIKE '$(domain)\bzzzt'
		)
BEGIN
	CREATE LOGIN [$(domain)\bzzzt]
	FROM WINDOWS WITH DEFAULT_DATABASE = [Sundae]
		,DEFAULT_LANGUAGE = [us_english]
END

IF NOT EXISTS (
		SELECT name
		FROM [sys].[database_principals]
		WHERE [type] = 'U'
			AND name = N'bzzzt'
		)
BEGIN
	CREATE USER [bzzzt]
	FOR LOGIN [$(domain)\bzzzt]
	WITH DEFAULT_SCHEMA = [dbo]
END

IF DATABASE_PRINCIPAL_ID('bzzzt_role') IS NULL
BEGIN
	CREATE ROLE bzzzt_role AUTHORIZATION [dbo]

	GRANT SELECT
		,VIEW DEFINITION
		ON SCHEMA::dbo
		TO bzzzt_role

	ALTER ROLE bzzzt_role ADD MEMBER [bzzzt];
END