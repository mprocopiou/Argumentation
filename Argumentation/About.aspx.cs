using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
using System.Threading;
using SbsSW.SwiPlCs;
using System.Diagnostics;
using System.Xml.Linq;


namespace Argumentation
{
    public class Attack
    {
        public string source { get; set; }
        public string target { get; set; }
    }

    public class Argument
    {
        public string Id { get; set; }
        public string Sm { get; set; }
        public string Su { get; set; }
        public string Cl { get; set; }
    }
    public partial class About : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void Submit_Click(object sender, System.EventArgs e)
        {         
            System.IO.File.WriteAllText(@"C:\Users\michael\Desktop\ABAscripts\proxdd\data\test2.pl", framework.Text);

            Process process = new Process();
            process.StartInfo.FileName = @"C:\Users\michael\Desktop\ABAscripts\proxdd\code\testprolog.bat";
            process.StartInfo.UseShellExecute = false;
            process.StartInfo.Arguments = claim.Text;
            process.Start();
            process.WaitForExit();

            Response.Redirect("WebForm1.aspx");
        }

        protected void TestProlog_Click(object sender, System.EventArgs e)
        {
        Process process = new Process();
        process.StartInfo.FileName = @"C:\Users\michael\Desktop\ABAscripts\proxdd\code\testprolog.bat"; 
        process.StartInfo.UseShellExecute = false;
        process.Start();
        process.WaitForExit();  
        }

        protected void Transform_Click(object sender, System.EventArgs e)
        {
            XDocument document = XDocument.Load(@"C:\Users\michael\Desktop\ABAscripts\proxdd\code\test.xml");
            IEnumerable<Argument> arguments = from a in document.Descendants("argument")
                                              select new Argument()
                                              {
                                                  Id = a.Element("number").Value,
                                                  Sm = a.Element("Sm").Value,
                                                  Su = a.Element("Su").Value,
                                                  Cl = a.Element("Cl").Value,
                                              };
            IEnumerable<Attack> attacks = from att in document.Descendants("attack")
                                          select new Attack()
                                          {
                                              source = att.Element("from").Value,
                                              target = att.Element("to").Value,
                                          };
            string nodesString = "";
            foreach(Argument argument in arguments) 
            {
                nodesString = nodesString + String.Format("{{\"number\":\"{0}\",\"Sm\":\"{1}\",\"Su\":\"{2}\",\"Cl\":\"{3}\"}},", 
                                                            argument.Id,argument.Sm,argument.Su,argument.Cl);
            }
            nodesString = nodesString.TrimEnd(',');

            string linksString = "";
            foreach (Attack attack in attacks)
            {
                List<Argument> argsList = arguments.ToList<Argument>();
                string source = argsList.FindIndex(argument => argument.Id == attack.source).ToString();
                string target = argsList.FindIndex(argument => argument.Id == attack.target).ToString();
                linksString = linksString + String.Format("{{\"source\":{0},\"target\":{1},\"value\":1}},", source, target);
            }
            linksString = linksString.TrimEnd(',');
            // MUST INCLUDE ROOT AS CLAIM!!! either wise target of link can be -1 (i.e arrange for target 0).
            string json = String.Format("{{ \"nodes\":[{0}],\"links\":[{1}]}}", nodesString, linksString);
        }
    }
}