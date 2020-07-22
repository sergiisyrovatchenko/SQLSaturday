using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace SQLInjection
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

                string sql = string.Format(@"SELECT * FROM dbo.Users WHERE UserID = {0}", args[0]);
                SqlCommand command = new SqlCommand(sql, connection);

                //string sql = @"SELECT * FROM dbo.Users WHERE UserID = @UserID";
                //SqlCommand command = new SqlCommand(sql, connection);
                //command.Parameters.AddWithValue("@UserID", args[0]);

                var list = new List<object>();
                var reader = command.ExecuteReader();

                while(reader.Read()) {}
            }
        }
    }
}
