using System;
using System.Data.SqlClient;

namespace Example
{
    class Program
    {
        static void Main()
        {
            var value = Console.ReadLine();
            
            using (SqlConnection conn = new SqlConnection())
            {
                conn.ConnectionString = @"Server=HOMEPC\SQL_2016;Database=AdventureWorks2014;Trusted_Connection=true";
                conn.Open();

                SqlCommand command = new SqlCommand(
                    string.Format("SELECT TOP(3) name FROM sys.objects WHERE schema_id = {0}", value), conn);

                //SqlCommand command = new SqlCommand("SELECT TOP(3) name FROM sys.objects WHERE schema_id = @schema_id", conn);
                //command.Parameters.Add(new SqlParameter("schema_id", value));

                using (SqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        Console.WriteLine(reader[0]);
                    }
                }
            }

            Console.ReadLine();
        }
    }
}