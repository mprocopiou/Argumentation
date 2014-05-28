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
    public partial class Result : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Request.QueryString["success"] == "false")
                    SolutionNotFound.Visible = true;
                framework.Text = (String)Session["Input"];
                claim.Text = (String)Session["Claim"];
                groundedProgramBox.Text = (String)Session["GroundedProg"];
                if (Session["Error"] != null)
                {
                    printErrors((List<String>)Session["Error"]);
                }
                Session["Error"] = null;
            }
        }

        protected void Submit_Click(object sender, System.EventArgs e)
        {
            string engineOutput = "";
            int engine = 1;
            //TODO do we need this?
            //TODO Could i mappath directly to prolog?
            string dir = Server.MapPath(@"~\");
            //string dir = @"~\";
            //TODO WHAT IF CAPS IN FILE NAME? WILL PROLOG STILL LOAD?!?
            //string filename = Path.GetRandomFileName();
            //filename = Path.ChangeExtension(filename, ".pl");
            if (Proxdd.Checked & Ideal.Checked)
            {
                dir = dir + @"Prolog\idealsemantics\proxdd\";
                engine = 3;
            }
            else if (Proxdd.Checked)
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
            //Cache Input.
            Session["Input"] = framework.Text;
            Session["Claim"] = claim.Text;
            bool correctInput = true;
            string groundedProgramStr;
            string testOutput = Parser.Parser.startParsing(testingParser, claim.Text, out correctInput, out groundedProgramStr);

            if (!correctInput)
            {
                List<String> errorList = new List<String>();
                errorList = testOutput.Split(new char[] { '\n' }, StringSplitOptions.RemoveEmptyEntries).ToList<String>();
                Session["Error"] = errorList;
                Response.Redirect(String.Format("Result.aspx?"));
            }
            else
            {
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
                else if (Ideal.Checked & Proxdd.Checked)
                    runProlog = dir + @"code\runIb.pl";
                //TODO might need to wrap up Engine in try catch.
                //Environment.SetEnvironmentVariable("SWI_HOME_DIR", @"C:\Program Files (x86)\swipl\boot32.prc");  // or boot64.prc
                //string testVar = Environment.GetEnvironmentVariable("SWI_HOME_DIR");  // or boot64.prc
                List<String> solution = new List<string>();
                try
                {
                    runProxddEngine(dir, termList, runProlog, solution);
                }
                catch { }
                if (solution.Count > 0)
                {
                    Session["Result"] = solution;
                    Response.Redirect(String.Format("Result.aspx?success=true"));
                }
                else
                {
                    Response.Redirect(String.Format("Result.aspx?success=false"));
                }
                //TODO Batch Stuff hopefully I will substitute.

                //process.StartInfo.FileName = strategy;
                //process.StartInfo.UseShellExecute = false;
                //process.StartInfo.Arguments = claim.Text;
                //process.Start();
                //process.WaitForExit();                        
            }

        }

        private void printErrors(List<String> errorList)
        {
            ErrorRepeater.DataSource = errorList;
            ErrorRepeater.DataBind();
        }

        private void runProxddEngine(string dir, string termList, string runProlog, List<String> solution)
        {
            if (!PlEngine.IsInitialized)
            {
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
            }
        }
    }
}