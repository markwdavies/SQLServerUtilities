USE [master]
GO
/* ------ -- ------- -- ------ ------ ----
   script to install or update stored proc 
   ------ -- ------- -- ------ ------ ---- */
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_WhatIsRunning') DROP PROC [sp_WhatIsRunning]
GO
/* =====================================================================================
   https://github.com/markwdavies/SQLServerUtilities/StoredProcs
   
   Procedure :	sp_WhatIsRunning
   
   Version   :	2.1
   Last Amended : 11th April 2023 

   Description:	Display details of running sessions

   Usage :		EXEC sp_WhatIsRunning

   ===================================================================================== */
CREATE PROCEDURE [dbo].[sp_WhatIsRunning]

AS

BEGIN

SELECT  r.start_time [Start Time]
      , session_id [SPID]
      , DB_NAME(database_id) [Database]
      , SUBSTRING(t.text , ( r.statement_start_offset / 2 ) + 1 ,
                  CASE WHEN ((statement_end_offset = -1)
                            OR (statement_end_offset = 0))
                       THEN ( DATALENGTH(t.text) - r.statement_start_offset
                              / 2 ) + 1
                       ELSE ( r.statement_end_offset
                              - r.statement_start_offset ) / 2 + 1
                  END) [Executing SQL]
      , status
      , command
      , wait_type
      , wait_time
      , wait_resource
      , last_wait_type
FROM    sys.dm_exec_requests r
        OUTER APPLY sys.dm_exec_sql_text(sql_handle) t
WHERE   session_id != @@SPID -- don't show this query
        AND session_id > 50 -- don't show system queries
ORDER BY r.start_time;

END