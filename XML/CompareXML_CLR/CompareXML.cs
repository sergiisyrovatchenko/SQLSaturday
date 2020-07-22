using System.Data.SqlTypes;
using Microsoft.XmlDiffPatch;
using System.Xml;

public class UserDefinedFunctions
{
    public static SqlBoolean CompareXML_CLR (SqlXml xml1, SqlXml xml2, SqlBoolean ignoreOrder)
    {
        bool empty1 = xml1.IsNull || string.IsNullOrEmpty(xml1.Value);
        bool empty2 = xml2.IsNull || string.IsNullOrEmpty(xml2.Value);

        if (empty1 && empty2)
            return true;

        if (empty1 || empty2)
            return false;

        XmlDocument doc1 = GetXmlValue(xml1);
        XmlDocument doc2 = GetXmlValue(xml2);

        XmlDiffOptions option = XmlDiffOptions.IgnoreNamespaces | XmlDiffOptions.IgnorePrefixes |
            (ignoreOrder ? XmlDiffOptions.IgnoreChildOrder : XmlDiffOptions.None);

        XmlDiff diff = new XmlDiff(option);
        return diff.Compare(doc1, doc2);
    }

    private static XmlDocument GetXmlValue(SqlXml x)
    {
        XmlDocument doc = new XmlDocument();
        doc.LoadXml(string.Format("<ROOT>{0}</ROOT>", x.Value));

        return doc;
    }
};