using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace Compilations
{
    class Program
    {
        static void Main(string[] args)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["bigData"].ConnectionString;

            SqlConnection connection = new SqlConnection(connectionString);
            using (connection)
            {
                connection.Open();

                for (int i = 0; i < 2500; i++)
                { 
                    SqlCommand command = new SqlCommand("dbo.IsUserExists", connection);

                    SqlParameter parameter = new SqlParameter("@UserID", SqlDbType.Int);
                    parameter.Value = i;
                    parameter.IsNullable = false;
                    command.Parameters.Add(parameter);

                    command.CommandType = CommandType.StoredProcedure;

                    var reader = command.ExecuteReader();
                    while (reader.Read()) {}
                    reader.Close();
                }
            }
        }
    }
}
