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
using System.Collections.Specialized;


namespace Argumentation
{
    public partial class WebForm1 : System.Web.UI.Page
    {

        public class Attack
        {
            public string source { get; set; }
            public string target { get; set; }
        }

        public class Node
        {
            public string name { get; set; }
            public string id { get; set; }
            public string type { get; set; }
            public string action { get; set; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            build_graph();
        }

        protected void build_graph()
        {
            List<String> solutions = (List<String>)Session["Result"];
            string[] qstring = Request.QueryString["engine"].Split(';');
            string engine = qstring[0];
            //string outputXml = qstring[1] + ".xml";
            string loadFile = "";
            string dir = Server.MapPath(@"~\Prolog");
            //if (engine=="1")
            //    loadFile = dir + @"\proxdd\data\" + outputXml;
            //else if (engine=="2")
            //    loadFile = dir + @"\grapharg\data\" + outputXml;


            //deleteFile(loadFile);
            //TODO Multiple Solutions.
            List<String> parsedSol = parseSolution(solutions[0]);

            List<Node> arguments = new List<Node>();
            List<Attack> attacks = new List<Attack>();

            foreach (var elem in parsedSol)
            {
                string[] splitelem = elem.Split(new char[] {'('},2);
                string head = splitelem[0];
                string details = splitelem[1].TrimEnd(')');

                List<String> parsedDetails = parseDetails(details);

                if (head == "node")
                {
                    Node node = new Node
                    {
                        id = parsedDetails[0],
                        name = parsedDetails[1],
                        type = parsedDetails[2],
                        action = parsedDetails[3],
                    };
                    arguments.Add(node);          
                }
                else if (head == "attack")
                {
                    Attack attack = new Attack()
                    {
                        source = parsedDetails[0],
                        target = parsedDetails[1],
                    };
                    attacks.Add(attack);
                }
            }
            //XDocument document = XDocument.Load(loadFile);
            //IEnumerable<Node> arguments = from a in document.Descendants("node")
            //                                  select new Node()
            //                                  {
            //                                      id = a.Element("id").Value,
            //                                      name = a.Element("name").Value,
            //                                      type = a.Element("type").Value,
            //                                      action = a.Element("action").Value,
            //                                  };
            //IEnumerable<Attack> attacks = from att in document.Descendants("attack")
            //                              select new Attack()
            //                              {
            //                                  source = att.Element("source").Value,
            //                                  target = att.Element("target").Value,
            //                              };
            string nodesString = "";
            foreach (Node argument in arguments)
            {
                int shape = (argument.type == "Asm") ? 0 : 3;
                int colour = 0;
                if (argument.action == "support") { colour = 1; }
                else if (argument.action == "attack") { colour = 2;}
                if (argument.action == "claim") { colour = 3; }
                nodesString = nodesString + String.Format("{{\"id\":\"{0}\",\"name\":\"{1}\",\"shape\":{2},\"group\":{3}}},",
                                                            argument.id, argument.name, shape, colour);
                //nodesString = nodesString + String.Format("{{\"number\":\"{0}\",);
            }
            nodesString = nodesString.TrimEnd(',');
            nodesSet.Value = nodesString;

            string linksString = "";
            foreach (Attack attack in attacks)
            {
                if (attack.target != "0")
                {
                    List<Node> argsList = arguments.ToList<Node>();                           
                    string source = argsList.FindIndex(argument => argument.id == attack.source).ToString();
                    string target = argsList.FindIndex(argument => argument.id == attack.target).ToString();
                    int group = (argsList[Int32.Parse(source)].type == "Asm") ? 0 : 1;
                    linksString = linksString + String.Format("{{\"source\":{0},\"target\":{1},\"value\":1,\"group\":{2}}},", source, target, group);
                }
            }
            linksString = linksString.TrimEnd(',');
            linksSet.Value = linksString;
            // MUST INCLUDE ROOT AS CLAIM!!! either wise target of link can be -1 (i.e arrange for target 0).
            string json = String.Format("{{ \"nodes\":[{0}],\"links\":[{1}]}}", nodesString, linksString);
            jsonstream.Value = json;

        }

        private List<string> parseDetails(string details)
        {
            List<string> parsedDetails = new List<string>();
            int index = 0;
            string currStr = "";
            foreach (char c in details)
            {
                string character = c.ToString();
                if (character == "," && index == 0)
                {
                    string finishedStr = currStr.ToString();
                    parsedDetails.Add(finishedStr);
                    currStr = "";
                }
                else if (character == "(")
                {
                    currStr = currStr + character;
                    index++;
                }
                else if (character == ")")
                {
                    currStr = currStr + character;
                    index--;
                }
                else
                {
                    currStr = currStr + character;
                }
            }
            string finalStr = currStr.ToString();
            parsedDetails.Add(finalStr);
            return parsedDetails;
        }

        private List<string> parseSolution(string solutionStr)
        {
            solutionStr = solutionStr.Trim('[',']');
            List<String> parsedStr = new List<string>();
            char[] charList = solutionStr.ToCharArray();
            int index = 0;
            string currString = "";
            foreach (char c in solutionStr)
            {
                string character = c.ToString();
                if (character == ")")
                {
                    index--;
                    currString = currString + character;
                    if (index == 0) {
                        String finishedStr = currString.ToString();
                        parsedStr.Add(finishedStr.ToString());
                        currString = "";
                    }
                }
                else if (character == "," && index == 0)
                {
                    //Skip
                }
                else if (character == "(")
                {
                    index++;
                    currString = currString + character;
                }
                else
                {
                    currString = currString + character;
                }
            }
            return parsedStr;
        }

        private void deleteFile(string file)
        {
            // Delete xml files.
            if ((System.IO.File.Exists(file)))
            {
                System.IO.File.Delete(file);
            }
            // Delete pl files.
            file = file.Replace(".xml", ".pl");
            if ((System.IO.File.Exists(file)))
            {
                System.IO.File.Delete(file);
            }
        }
    }
}