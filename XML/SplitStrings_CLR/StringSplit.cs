﻿using System.Collections;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;

public partial class UserDefinedFunctions
{
    [SqlFunction(FillRowMethodName = "FillRow_Multi", TableDefinition = "item nvarchar(4000)")]

    public static IEnumerator StringSplit_CLR (
        [SqlFacet(MaxSize = -1)]  SqlChars Input,
        [SqlFacet(MaxSize = 255)] SqlChars Delimiter
    )
    {
        return Input.IsNull || Delimiter.IsNull
            ? new StringSplit(new char[0], new char[0])
            : new StringSplit(Input.Value, Delimiter.Value);
    }

    public static void FillRow_Multi(object obj, out SqlString item)
    {
        item = new SqlString((string)obj);
    }

    public class StringSplit : IEnumerator
    {
        public StringSplit(char[] TheString, char[] Delimiter)
        {
            theString = TheString;
            stringLen = TheString.Length;
            delimiter = Delimiter;
            delimiterLen = (byte)(Delimiter.Length);
            isSingleCharDelim = (delimiterLen == 1);

            lastPos = 0;
            nextPos = delimiterLen * -1;
        }

        public object Current
        {
            get { return new string(theString, lastPos, nextPos - lastPos); }
        }

        public bool MoveNext()
        {
            if (nextPos >= stringLen)
                return false;

            lastPos = nextPos + delimiterLen;

            for (int i = lastPos; i < stringLen; i++)
            {
                bool matches = true;

                if (isSingleCharDelim)
                {
                    if (theString[i] != delimiter[0])
                        matches = false;
                }
                else
                {
                    for (byte j = 0; j < delimiterLen; j++)
                    {
                        if (((i + j) >= stringLen) || (theString[i + j] != delimiter[j]))
                        {
                            matches = false;
                            break;
                        }
                    }
                }

                if (matches)
                {
                    nextPos = i;

                    if ((nextPos - lastPos) > 0)
                        return true;
                    else
                    {
                        i += (delimiterLen - 1);
                        lastPos += delimiterLen;
                    }
                }
            }

            lastPos = nextPos + delimiterLen;
            nextPos = stringLen;

            return ((nextPos - lastPos) > 0)
                ? true
                : false;
        }

        public void Reset()
        {
            lastPos = 0;
            nextPos = delimiterLen * -1;
        }

        private int lastPos;
        private int nextPos;

        private readonly char[] theString;
        private readonly char[] delimiter;
        private readonly int stringLen;
        private readonly byte delimiterLen;
        private readonly bool isSingleCharDelim;
    }
};