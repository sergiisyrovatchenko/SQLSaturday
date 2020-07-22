using System.Data.SqlTypes;
using System.IO;
using System.IO.Compression;
using Microsoft.SqlServer.Server;

public partial class Compress
{
    [SqlFunction(IsDeterministic = true, IsPrecise = true, DataAccess = DataAccessKind.None)]
    public static SqlBytes BinaryCompress(SqlBytes input)
    {
         if (input.IsNull)
             return SqlBytes.Null;

        using (MemoryStream result = new MemoryStream())
        {
            using (DeflateStream deflateStream = new DeflateStream(result, CompressionMode.Compress, true))
            {
                deflateStream.Write(input.Buffer, 0, input.Buffer.Length);
                deflateStream.Flush();
                deflateStream.Close();
            }
            return new SqlBytes(result.ToArray());
        } 
    }

    [SqlFunction(IsDeterministic = true, IsPrecise = true, DataAccess = DataAccessKind.None)]
    public static SqlBytes BinaryDecompress(SqlBytes input)
    {
        if (input.IsNull)
            return SqlBytes.Null;

        int batchSize = 32768;
        byte[] buf = new byte[batchSize];

        using (MemoryStream result = new MemoryStream())
        {
            using (DeflateStream deflateStream = new DeflateStream(input.Stream, CompressionMode.Decompress, true))
            {
                int bytesRead;
                while ((bytesRead = deflateStream.Read(buf, 0, batchSize)) > 0)
                    result.Write(buf, 0, bytesRead);
            }
            return new SqlBytes(result.ToArray());
        } 
    }
}
