using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace ParameterSniffing
{
    class Program
    {
        static void Main(string[] args)
        {
            if (args.Length != 1)
                return;

            string connectionString = ConfigurationManager.ConnectionStrings["bigData"].ConnectionString;

            SqlConnection connection = new SqlConnection(connectionString);
            using (connection)
            {
                connection.Open();
                SqlCommand command = new SqlCommand(@"dbo.GetUserCount", connection);

                SqlParameter parameter = new SqlParameter("@City", SqlDbType.VarChar, 30);
                parameter.Value = args[0];
                parameter.IsNullable = false;
                command.Parameters.Add(parameter);

                command.CommandType = CommandType.StoredProcedure;

                var list = new List<object>();
                var reader = command.ExecuteReader();

                while(reader.Read()) {}
            }
        }
    }
}
