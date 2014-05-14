using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Argumentation
{
    public class Assumption
    {
        public string id { get; set; }
    }

    public class Contrary : Assumption
    {
        public string assumId { get; set; }
    }

    public class Rule : Assumption
    {
        public string supportiveID { get; set; }
        public string disputingID { get; set; }
    }

    public partial class Assumptions : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack == false)
            {

            }
            if (string.IsNullOrEmpty(Session["assumptions"] as string))
            {
                List<Assumption> assumptions;
            }

        }

        protected void AddAnotherAssumption_Click(object sender, EventArgs e)
        {
            GetAssumptionsandContraries();
            Response.Redirect("Assumptions.aspx");
        }

        private void GetAssumptionsandContraries()
        {
            if (!string.IsNullOrEmpty(AssumptionName.SelectedItem.Text))
            {
                string assumption = (AssumptionName.SelectedIndex == -1) ? AssumptionName.Text : AssumptionName.SelectedItem.Text;
                Assumption assumptionTemp = new Assumption();
                assumptionTemp.id = assumption;

                Contrary contraryTemp = new Contrary();
                contraryTemp.id = (ContraryName.SelectedIndex == -1) ? ContraryName.Text : ContraryName.SelectedItem.Text;
                contraryTemp.assumId = assumption;

                List<Assumption> assumptions = new List<Assumption>();
                if (!string.IsNullOrEmpty(Session["assumptions"].ToString()))
                {
                    assumptions = (List<Assumption>)Session["assumptions"];
                }
                assumptions.Add(assumptionTemp);

                List<Contrary> contraries = new List<Contrary>();
                if (!string.IsNullOrEmpty(Session["contraries"].ToString()))
                {
                    contraries = (List<Contrary>)Session["contraries"];
                }
                contraries.Add(contraryTemp);
            }
        }

        protected void AssumptionsDone_Click(object sender, EventArgs e)
        {
            GetAssumptionsandContraries();
            Response.Redirect("About.aspx");
        }
    }
}