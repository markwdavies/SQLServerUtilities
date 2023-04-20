USE [master]
GO
/* ------ -- ------- ------ -----
   script to remove  stored procs 
   ------ -- ------- ------ ----- */
/* =====================================================================================
   https://github.com/markwdavies/SQLServerUtilities/StoredProcs

   Last Amended : 11th April 2023 

   Description:	This script will remove any of the stored procs installed from 
                  this repository

   ===================================================================================== */
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_WhatAreMyLuckyNumbers') DROP PROC [sp_WhatAreMyLuckyNumbers] ;
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_WhatWasRestored') DROP PROC [sp_WhatWasRestored] ;
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_WhereAreTheBackups') DROP PROC [sp_WhereAreTheBackups] ;
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_WhereAreTheFiles') DROP PROC [sp_WhereAreTheFiles] ;
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_WhatIsRunning') DROP PROC [sp_WhatIsRunning] ;