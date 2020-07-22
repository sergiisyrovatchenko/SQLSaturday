using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace ConvertImplicit
{
    class Program
    {
        static void Main(string[] args)
        {
            if (args.Length != 1)
                return;

            string connectionString = ConfigurationManager.ConnectionStrings["bigData"].ConnectionString;
            string sql = @"SELECT COUNT(*), COUNT(DISTINCT FirstName)
                           FROM dbo.Users
                           WHERE City = @City";

            SqlConnection connection = new SqlConnection(connectionString);
            using (connection)
            {
                connection.Open();
                SqlCommand command = new SqlCommand(sql, connection);

                command.Parameters.AddWithValue("@City", args[0]);

                //SqlParameter parameter = new SqlParameter("@City", SqlDbType.VarChar, 30);
                //parameter.Value = args[0];
                //parameter.IsNullable = false;
                //command.Parameters.Add(parameter);

                command.CommandType = CommandType.Text;

                var list = new List<object>();
                var reader = command.ExecuteReader();

                while(reader.Read()) {}
            }
        }
    }
}
