Const CONNECT_STRING = "Provider=SQLOLEDB;Data Source=HOMEPC\SQL_2016;Database=tempdb;Integrated Security=SSPI"
Set objBL = CreateObject("SQLXMLBulkLoad.SQLXMLBulkload.4.0")
objBL.ErrorLogFile = "X:\sample2.log"
objBL.CheckConstraints = True
objBL.KeepIdentity = True
objBL.ConnectionString = CONNECT_STRING
objBL.Execute "D:\PROJECT\XML\SQLXMLBulkLoad\sample2.xsd", "X:\sample2.xml"