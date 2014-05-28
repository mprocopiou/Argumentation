﻿<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Result.aspx.cs" Inherits="Argumentation.Result" %>

<asp:Content runat="server" ID="BodyContent" ContentPlaceHolderID="MainContent">
    <script type="text/javascript">
        function showGroundPanel(myBtn) {            
            var groundedBox = document.getElementById('<%=groundedProgramBox.ClientID %>');
            groundedBox.style.display = "block";

            var hideBtn = document.getElementById('<%=hideGroundedBtn.ClientID %>');
            hideBtn.style.display = "block";

            myBtn.style.display = "none";

            return false;
        }

        function hideGroundPanel(myBtn) {
            var groundedBox = document.getElementById('<%=groundedProgramBox.ClientID %>');
            groundedBox.style.display = "none";

            var showBtn = document.getElementById('<%=showGroundedBtn.ClientID %>');
            showBtn.style.display = "block";

            myBtn.style.display = "none";

            return false;
        }
</script>
    <asp:Label runat="server" ID="SolutionNotFound" Visible="false" Text="No Solution was found for the claim." Font-Size="Large" ForeColor="Red"></asp:Label>
    <iframe src="WebForm1.aspx?success=<%= Request.QueryString["success"] %>" width = 960 height = 500 scrolling="no" style="border:solid; background: #FFFFFF"></iframe>    
     <div>
        <asp:Repeater id="ErrorRepeater" runat="server">

              <HeaderTemplate>
                 <table border="1">
              </HeaderTemplate>

              <ItemTemplate>
                 <tr>
                    <td style="font-size:medium;color:red;"> <%# Container.DataItem %> </td>
                 </tr>
              </ItemTemplate>

              <FooterTemplate>
                 </table>
              </FooterTemplate>

        </asp:Repeater>
     </div>
    <div>
        <asp:TextBox Rows="10" TextMode="MultiLine" runat="server" id="framework"/>
    </div>
    <div>
        <asp:TextBox Rows="10"  ReadOnly="true" TextMode="MultiLine" runat="server" id="groundedProgramBox" style="display:none;"/>
    </div>
    <div>
        <asp:Button runat="server" ID="showGroundedBtn" OnClientClick="return showGroundPanel(this);" Text="Show Grounded" />  
    </div>
    <div>
        <asp:Button runat="server" ID="hideGroundedBtn" OnClientClick="return hideGroundPanel(this);" Text="Hide Grounded" style="display:none;"/>  
    </div>
    <div>
        <asp:TextBox runat="server" id="claim"/>
    </div>
    <div>
        <table>
            <tr>
                <td style="padding:0;"><asp:Label ID="AdmissibleText" runat="server" Text="Admissible" /></td>
                <td style="padding:0;">                    
                    <asp:RadioButton id="Admissible" Checked="true" GroupName="Semantics" runat="server" TextAlign="Left" /> 
                </td>
                <td style="padding:0;"><asp:Label ID="GroundedText" runat="server" Text="Grounded" /></td>
                <td style="padding:0;">
                    <asp:RadioButton id="Grounded" GroupName="Semantics" runat="server" />
                </td>
                <td style="padding:0;"><asp:Label ID="IdealText" runat="server" Text="Ideal" /></td>
                <td style="padding:0;">
                    <asp:RadioButton id="Ideal" GroupName="Semantics" runat="server" />
                </td>
            </tr>
            <tr>
                <td style="padding:0;"><asp:Label ID="ProxddText" runat="server" Text="Proxdd" /></td>
                <td style="padding:0;">                    
                    <asp:RadioButton id="Proxdd" Checked="true" GroupName="Engine" runat="server" TextAlign="Left" /> 
                </td>
                <td style="padding:0;"><asp:Label ID="GraphargText" runat="server" Text="Grapharg" /></td>
                <td style="padding:0;">
                    <asp:RadioButton id="Grapharg" GroupName="Engine" runat="server" />
                </td>
            </tr>
        </table>

        <%-- 
        <asp:RadioButtonList ID="SemanticsList" TextAlign="Left" RepeatLayout="Table" RepeatColumns="2" AutoPostBack="false" runat="server">
            <asp:ListItem Selected="True" Value="0" Text="Admissable"/>
            <asp:ListItem Value="1"  Text="Grounded"/>
        </asp:RadioButtonList>
            --%>
    </div>
    <div>
        <asp:Button runat="server" ID="Submit" OnClick="Submit_Click" Text="Submit" />  
    </div>
</asp:Content>