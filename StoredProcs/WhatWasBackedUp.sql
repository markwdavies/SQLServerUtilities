USE [master]
GO

/* ------ -- ------- -- ------ ------ ----
   script to install or update stored proc 
   ------ -- ------- -- ------ ------ ---- */
IF EXISTS (
        SELECT 1
        FROM sys.procedures
        WHERE name = 'sp_WhatWasBackedUp'
        )
    DROP PROC [sp_WhatWasBackedUp]
GO

/* =====================================================================================
   https://github.com/markwdavies/SQLServerUtilities/StoredProcs
   
   Procedure :	sp_WhatWasBackedUp
   
   Version   :	1.1
   Last Amended : 30th october 2023 

   Description:	Display details of latest DB Backups for each DB on current instance

   Parameters :	@DBName (optional) 
				Database Name
   				  NULL for all (default)
				@FullBackupsOnly (optional) 
				  0 for all latest backups (default)
				  1 for details of Full Backups only

   Usage :		EXEC sp_WhatWasBackedUp
				@DBName = 'MyDB' , @FullBackupsOnly = 1
   ===================================================================================== */
CREATE PROCEDURE [dbo].[sp_WhatWasBackedUp] (
    @DBName NVARCHAR(128) = NULL
    ,@FullBackupsOnly BIT = 0
    )
AS
BEGIN
    SELECT TOP 1000 bs.database_name AS [Database Name]
        ,MAX(bs.backup_start_date) AS [Backup Started]
        ,CASE bs.[type]
            WHEN 'D'
                THEN 'Full'
            WHEN 'I'
                THEN 'Differential'
            WHEN 'L'
                THEN 'Transaction Log'
            ELSE 'Not Known'
            END AS [Backup Type]
    FROM msdb.dbo.backupset bs
    WHERE (
            (bs.database_name LIKE @DBName)
            OR (@DBName IS NULL)
            )
        AND (
            (bs.type = 'D')
            OR (@FullBackupsOnly = 0)
            )
    GROUP BY bs.database_name
        ,bs.[type]
    ORDER BY MAX(bs.backup_start_date) DESC;
END
GO


