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
            XDocument document = XDocument.Load(@"C:\Users\michael\Desktop\ABAscripts\proxdd\data\test2.xml");
            IEnumerable<Node> arguments = from a in document.Descendants("node")
                                              select new Node()
                                              {
                                                  id = a.Element("id").Value,
                                                  name = a.Element("name").Value,
                                                  type = a.Element("type").Value,
                                                  action = a.Element("action").Value,
                                              };
            IEnumerable<Attack> attacks = from att in document.Descendants("attack")
                                          select new Attack()
                                          {
                                              source = att.Element("source").Value,
                                              target = att.Element("target").Value,
                                          };
            string nodesString = "";
            foreach (Node argument in arguments)
            {
                int shape = (argument.type == "Asm") ? 0 : 3;
                int colour = 0;
                if (argument.action == "support") { colour = 1; }
                else if (argument.action == "attack") { colour = 2;}
                if (argument.id == "s0_0") { colour = 3; }
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
    }
}