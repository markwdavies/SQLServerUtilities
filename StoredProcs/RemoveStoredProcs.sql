USE [master]
GO
/* ------ -- ------- ------ -----
   script to remove  stored procs 
   ------ -- ------- ------ ----- */
/* =====================================================================================
   https://github.com/markwdavies/SQLServerUtilities/StoredProcs

   Last Amended : October 2025

   Description:	This script will remove any of the stored procs installed from 
                  this repository

   ===================================================================================== */
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_WhatWasRestored') DROP PROC [sp_WhatWasRestored] ;
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_WhereAreTheBackups') DROP PROC [sp_WhereAreTheBackups] ;
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_WhereAreTheFiles') DROP PROC [sp_WhereAreTheFiles] ;
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_WhatIsRunning') DROP PROC [sp_WhatIsRunning] ;
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_WhatWasBackedUp') DROP PROC [sp_WhatWasBackedUp] ;
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'WhatIsUsingTempDB') DROP PROC [WhatIsUsingTempDB] ;