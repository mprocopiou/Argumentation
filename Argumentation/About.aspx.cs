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

        protected void Assumption_Redirect(object sender, System.EventArgs e)
        {
            Response.Redirect("Assumptions.aspx");
        }

        protected void Rule_Redirect(object sender, System.EventArgs e)
        {
            Response.Redirect("Rules.aspx");
        }

        protected void Submit_Click(object sender, System.EventArgs e)
        {        
            string engineOutput ="";
            int engine = 1;
            //TODO do we need this?
            //TODO Could i mappath directly to prolog?
            string dir = Server.MapPath(@"~\");
            //string dir = @"~\";
            //TODO WHAT IF CAPS IN FILE NAME? WILL PROLOG STILL LOAD?!?
            //string filename = Path.GetRandomFileName();
            //filename = Path.ChangeExtension(filename, ".pl");
            if (Proxdd.Checked)
            {
                dir = dir + @"Prolog\proxdd\";
               // engineOutput = dir + @"data\" + filename;
                engine = 1;
            }
            else if (Grapharg.Checked)
            {
                dir = dir + @"Prolog\grapharg\";
               // engineOutput = dir + @"data\" + filename;
                engine = 2;
            }

          //  System.IO.File.WriteAllText(engineOutput, framework.Text);

            // TODO adding the ParserGrounder.
            //string testingParser = "asm(aasdd,b){X=1,2;}.t(X) <- [p(X),aasdd(X)]. p(X)<- [r(X)]. s(X) <- [r(X)].p(X)<-[r(X),t(X)].r(X) <-[aasdd(X)].";
            string testingParser = framework.Text;
            string testOutput = Parser.Parser.startParsing(testingParser);
            // TODO might need to change these when grounder is added.
            string termString = System.Text.RegularExpressions.Regex.Replace(testOutput, @"\s", "");
            string termList = termString.Replace('.', ',');
            termList = "[" + termList.TrimEnd(',') + "]";

            string runProlog = "";
            // TODO possibly redundant Engine check because of dir being assigned above.
            if (Admissible.Checked & Proxdd.Checked)            
                runProlog = dir + @"code\runAb.pl";            
            else if (Grounded.Checked & Proxdd.Checked)            
                runProlog = dir + @"code\runGb.pl";            
            else if (Admissible.Checked & Grapharg.Checked)
                runProlog = dir + @"code\runAb.pl";
            else if (Grounded.Checked & Grapharg.Checked)
                runProlog = dir + @"code\runGb.pl";
            //TODO might need to wrap up Engine in try catch.
            //Environment.SetEnvironmentVariable("SWI_HOME_DIR", @"C:\Program Files (x86)\swipl\boot32.prc");  // or boot64.prc
            //string testVar = Environment.GetEnvironmentVariable("SWI_HOME_DIR");  // or boot64.prc
            if (!PlEngine.IsInitialized)
            {
                List<String> solution = new List<string>();
                bool test = File.Exists(dir);
                String[] param = { "-q", "-f", runProlog };  // suppressing informational and banner messages
                PlEngine.Initialize(param);
                
                using (PlQuery q = new PlQuery("loads(" + termList + "),sxdd(" + claim.Text + ",X,Y)"))
                {
                    int idx = 0;
                    foreach (PlQueryVariables v in q.SolutionVariables)
                    {
                        solution.Add(v["Y"].ToString());
                    }
                }

                ////using (PlQuery q = new PlQuery("sxdd(p,X)"))
                //using (PlQuery q = new PlQuery("loadf(" + filename.Remove(filename.Length -3) + "),sxdd(" + claim.Text + ",X,Y)"))                
                //{
                //    int idx = 0;
                //    foreach (PlQueryVariables v in q.SolutionVariables)
                //    {
                //        solution.Add(v["Y"].ToString());
                //    }
                //}
                PlEngine.PlCleanup();
                Session["Result"] = solution;
            }

            //TODO Batch Stuff hopefully I will substitute.

            //process.StartInfo.FileName = strategy;
            //process.StartInfo.UseShellExecute = false;
            //process.StartInfo.Arguments = claim.Text;
            //process.Start();
            //process.WaitForExit();                        

            Response.Redirect(String.Format("Result.aspx?engine={0}", engine));
        }

        protected void TestProlog_Click(object sender, System.EventArgs e)
        {
        Process process = new Process();
        process.StartInfo.FileName = @"C:\Users\michael\Desktop\ABAscripts\proxdd\code\testprolog.bat"; 
        process.StartInfo.UseShellExecute = false;
        process.Start();
        process.WaitForExit();  
        }

        //TODO Most likely not required!!!! CHECK AND DELETE BELOW!

        //protected void Transform_Click(object sender, System.EventArgs e)
        //{
        //    XDocument document = XDocument.Load(@"C:\Users\michael\Desktop\ABAscripts\proxdd\code\test.xml");
        //    IEnumerable<Argument> arguments = from a in document.Descendants("argument")
        //                                      select new Argument()
        //                                      {
        //                                          Id = a.Element("number").Value,
        //                                          Sm = a.Element("Sm").Value,
        //                                          Su = a.Element("Su").Value,
        //                                          Cl = a.Element("Cl").Value,
        //                                      };
        //    IEnumerable<Attack> attacks = from att in document.Descendants("attack")
        //                                  select new Attack()
        //                                  {
        //                                      source = att.Element("from").Value,
        //                                      target = att.Element("to").Value,
        //                                  };
        //    string nodesString = "";
        //    foreach(Argument argument in arguments) 
        //    {
        //        nodesString = nodesString + String.Format("{{\"number\":\"{0}\",\"Sm\":\"{1}\",\"Su\":\"{2}\",\"Cl\":\"{3}\"}},", 
        //                                                    argument.Id,argument.Sm,argument.Su,argument.Cl);
        //    }
        //    nodesString = nodesString.TrimEnd(',');

        //    string linksString = "";
        //    foreach (Attack attack in attacks)
        //    {
        //        List<Argument> argsList = arguments.ToList<Argument>();
        //        string source = argsList.FindIndex(argument => argument.Id == attack.source).ToString();
        //        string target = argsList.FindIndex(argument => argument.Id == attack.target).ToString();
        //        linksString = linksString + String.Format("{{\"source\":{0},\"target\":{1},\"value\":1}},", source, target);
        //    }
        //    linksString = linksString.TrimEnd(',');
        //    // MUST INCLUDE ROOT AS CLAIM!!! either wise target of link can be -1 (i.e arrange for target 0).
        //    string json = String.Format("{{ \"nodes\":[{0}],\"links\":[{1}]}}", nodesString, linksString);
        //}
    }
}